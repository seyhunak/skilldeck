import SkilldeckCore
import SwiftUI

// MARK: - Resource card

struct ResourceCard: View {
    @Environment(AppModel.self) private var model
    let resource: Resource

    var body: some View {
        Button { model.openResource(resource.id) } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 10) {
                    TypeIcon(type: resource.type, size: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(resource.name).font(.headline).lineLimit(2).multilineTextAlignment(.leading)
                        Text(model.index?.domainName(resource.domain) ?? resource.domain).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing, spacing: 4) {
                        if resource.featured { Image(systemName: "star.circle.fill").foregroundStyle(.yellow).help("Featured") }
                        if model.installedIDs.contains(resource.id) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).help("Installed") }
                    }
                }
                Text(resource.description).font(.callout).foregroundStyle(.secondary).lineLimit(3).multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 4) {
                    TypeBadge(type: resource.type, compact: true)
                    ForEach(resource.tags.prefix(2), id: \.self) { TagChip(text: $0) }
                }
                Spacer(minLength: 0)
                HStack {
                    AuthorButton(author: resource.author)
                    Spacer()
                    CompatibilityStrip(resource: resource)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 176, alignment: .topLeading)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(.separator.opacity(0.6)))
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .contextMenu { ResourceContextMenu(resource: resource) }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(resource.type.displayName): \(resource.name). \(resource.description)")
    }
}

struct ResourceContextMenu: View {
    @Environment(AppModel.self) private var model
    let resource: Resource
    var body: some View {
        Button("Open") { model.openResource(resource.id) }
        Button(model.isFavorite(resource.id) ? "Remove from Favorites" : "Add to Favorites") { model.toggleFavorite(resource.id) }
        Button("Copy Content") { model.copyToPasteboard(model.primaryContent(resource), label: resource.type == .prompt ? "prompt" : "content") }
        if !model.library.collections.isEmpty {
            Menu("Add to Collection") {
                ForEach(model.library.collections) { c in Button(c.name) { model.addToCollection(c.id, resource.id) } }
            }
        }
        Button("Export…") { model.export(resources: [resource], suggestedName: resource.id) }
    }
}

struct ResourceGrid: View {
    let resources: [Resource]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260, maximum: 420), spacing: 12)], spacing: 12) {
            ForEach(resources) { ResourceCard(resource: $0) }
        }
    }
}

struct ResourceRow: View {
    @Environment(AppModel.self) private var model
    let resource: Resource
    var body: some View {
        HStack(spacing: 10) {
            TypeIcon(type: resource.type, size: 26)
            VStack(alignment: .leading, spacing: 1) {
                Text(resource.name).font(.body.weight(.medium))
                Text(resource.description).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            if model.installedIDs.contains(resource.id) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
            Text("v\(resource.version)").font(.caption.monospacedDigit()).foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Discover

struct DiscoverView: View {
    @Environment(AppModel.self) private var model

    struct Shelf: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let resources: [Resource]
        var seeAll: (() -> Void)?
    }

    var body: some View {
        if let index = model.index {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    hero(index)
                    if !model.searchText.isEmpty {
                        searchResults
                    } else {
                        ForEach(shelves(index)) { shelf in
                            if !shelf.resources.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    SectionHeader(title: shelf.title, subtitle: shelf.subtitle, action: shelf.seeAll)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: 12) {
                                            ForEach(shelf.resources.prefix(12)) { ResourceCard(resource: $0).frame(width: 290) }
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }
                        }
                        collectionsShelf(index)
                        contributorsShelf(index)
                    }
                }
                .padding(24)
            }
            .navigationTitle("Discover")
            .searchable(text: Bindable(model).searchText, placement: .toolbar, prompt: "Search agents, skills, prompts, routines")
        }
    }

    private var searchResults: some View {
        let results = model.search?.search(model.searchText, installedIDs: model.installedIDs) ?? []
        return VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Results for “\(model.searchText)”", subtitle: "\(results.count) resources")
            if results.isEmpty {
                EmptyStateView(title: "No matches", symbol: "magnifyingglass", message: "Try a use case like “code review” or “competitor research”.")
            } else {
                ResourceGrid(resources: results)
            }
        }
    }

    private func hero(_ index: CatalogIndex) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("What do you want to get done?").font(.largeTitle.weight(.bold))
            Text("\(index.resources.count) agents, skills, prompts, and routines from \(index.catalog.contributors.count) contributor\(index.catalog.contributors.count == 1 ? "" : "s") — browsable, searchable, and installable offline.")
                .font(.title3).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(quickTasks, id: \.0) { title, query in
                    Button(title) { model.searchText = query }.buttonStyle(.bordered).controlSize(.small)
                }
            }
            .padding(.top, 6)
        }
    }

    private let quickTasks = [("Review a pull request", "pull request review"), ("Evaluate RAG", "rag evaluation"),
                              ("Threat model", "threat model"), ("Write a PRD", "prd"), ("Analyze SQL", "sql")]

    private func byUseCase(_ index: CatalogIndex, _ cases: Set<String>, types: Set<ResourceType>? = nil) -> [Resource] {
        index.resources.filter { !cases.isDisjoint(with: $0.useCases) && (types?.contains($0.type) ?? true) }
            .sorted { ($0.type == .agent ? 0 : 1, $0.name) < ($1.type == .agent ? 0 : 1, $1.name) }
    }

    private func inCollection(_ index: CatalogIndex, _ id: String) -> [Resource] {
        index.collectionsByID[id].map { index.resources(in: $0) } ?? []
    }

    func shelves(_ index: CatalogIndex) -> [Shelf] {
        let all = index.resources
        let col: (String) -> (() -> Void) = { id in { model.open(.collection(id)) } }
        return [
            Shelf(id: "featured", title: "Featured", subtitle: "Hand-picked by the maintainers", resources: all.filter(\.featured)),
            Shelf(id: "dev", title: "Recommended for Developers", subtitle: "Understand, review, test, and ship code",
                  resources: inCollection(index, "complete-software-development-toolkit"), seeAll: col("complete-software-development-toolkit")),
            Shelf(id: "aieng", title: "AI Engineering", subtitle: "Evaluate, observe, and optimize LLM features",
                  resources: inCollection(index, "ai-engineering-toolkit"), seeAll: col("ai-engineering-toolkit")),
            Shelf(id: "agent", title: "Build an AI Agent", subtitle: "Workflows, tools, MCP servers, and guardrails",
                  resources: inCollection(index, "ai-agent-development-toolkit"), seeAll: col("ai-agent-development-toolkit")),
            Shelf(id: "rag", title: "Build a RAG Application", subtitle: "From chunking to grounded, measured answers",
                  resources: inCollection(index, "rag-development-toolkit"), seeAll: col("rag-development-toolkit")),
            Shelf(id: "review", title: "Review a Codebase", subtitle: "Repository analysis and code review",
                  resources: byUseCase(index, ["code-review", "repository-analysis"])),
            Shelf(id: "competitors", title: "Research Competitors", subtitle: "Profiles, battlecards, and feature matrices",
                  resources: byUseCase(index, ["competitor-analysis"])),
            Shelf(id: "finance", title: "Analyze Financial Statements", subtitle: "Ratios, quality of earnings, and working capital",
                  resources: byUseCase(index, ["financial-statement-analysis"])),
            Shelf(id: "security", title: "Improve Application Security", subtitle: "Threat models, audits, and vulnerability triage",
                  resources: byUseCase(index, ["security-review", "threat-modeling"])),
            Shelf(id: "prd", title: "Generate Product Requirements", subtitle: "PRDs, user stories, and acceptance criteria",
                  resources: byUseCase(index, ["prd-generation"])),
            Shelf(id: "automate", title: "Automate Repetitive Tasks", subtitle: "Step-by-step routines you run with an AI assistant",
                  resources: all.filter { $0.type == .routine }.sorted { $0.name < $1.name }, seeAll: { model.select(.type(.routine)) }),
            Shelf(id: "recent", title: "Recently Added", subtitle: "Newest resources in the catalog",
                  resources: all.sorted { ($0.created ?? "", $0.name) > ($1.created ?? "", $1.name) }, seeAll: { model.select(.all) }),
            Shelf(id: "referenced", title: "Most Referenced", subtitle: "Resources other resources and collections build on most",
                  resources: all.sorted { (index.referenceCounts[$0.id] ?? 0, $1.name) > (index.referenceCounts[$1.id] ?? 0, $0.name) }),
        ]
    }

    private func collectionsShelf(_ index: CatalogIndex) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Curated Collections", subtitle: "Toolkits assembled for a job", action: { model.select(.collections) })
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(index.catalog.collections) { CollectionCard(collection: $0).frame(width: 300) }
                }
            }
        }
    }

    private func contributorsShelf(_ index: CatalogIndex) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Community Contributors", subtitle: "The people behind the catalog", action: { model.select(.contributors) })
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(index.catalog.contributors) { ContributorCard(contributor: $0).frame(width: 260) }
                }
            }
        }
    }
}

// MARK: - Browser with search, filters, sorting

struct ResourceBrowserView: View {
    @Environment(AppModel.self) private var model
    let title: String
    let fixedType: ResourceType?
    @State private var filters = SearchFilters()
    @State private var sort: SearchSort = .relevance
    @State private var showFilters = false
    @State private var asList = false
    @FocusState private var searchFocused: Bool

    var body: some View {
        @Bindable var model = model
        var f = filters
        if let fixedType { f.types = [fixedType] }
        let results = model.search?.search(model.searchText, filters: f, sort: sort, installedIDs: model.installedIDs) ?? []
        let suggestions = model.search?.suggestions(for: model.searchText) ?? []

        return VStack(spacing: 0) {
            if showFilters { FilterBar(filters: $filters, hideType: fixedType != nil).padding(.horizontal, 16).padding(.vertical, 10); Divider() }
            Group {
                if results.isEmpty {
                    EmptyStateView(title: "No resources match", symbol: "line.3.horizontal.decrease.circle",
                                   message: model.searchText.isEmpty ? "Clear some filters to see more." : "Try fewer words or clear filters.")
                } else if asList {
                    List(results) { r in
                        Button { model.openResource(r.id) } label: { ResourceRow(resource: r) }.buttonStyle(.plain)
                            .contextMenu { ResourceContextMenu(resource: r) }
                    }
                } else {
                    ScrollView { ResourceGrid(resources: results).padding(16) }
                }
            }
        }
        .navigationTitle(title)
        .navigationSubtitle("\(results.count) resource\(results.count == 1 ? "" : "s")")
        .searchable(text: $model.searchText, placement: .toolbar, prompt: "Search \(title.lowercased())")
        .searchSuggestions {
            ForEach(suggestions) { s in
                Label(s.text, systemImage: icon(for: s.kind))
                    .searchCompletion(s.kind == .resource ? s.text : s.text)
            }
        }
        .searchFocused($searchFocused)
        .onChange(of: model.searchFocusRequest) { searchFocused = true }
        .toolbar {
            ToolbarItemGroup {
                Picker("Sort", selection: $sort) { ForEach(SearchSort.allCases) { Text($0.displayName).tag($0) } }
                    .pickerStyle(.menu).help("Sort order")
                Button { showFilters.toggle() } label: {
                    Label("Filters", systemImage: filters.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                }
                .help("Show filters (\(filters.activeCount) active)")
                Picker("View", selection: $asList) {
                    Image(systemName: "square.grid.2x2").tag(false)
                    Image(systemName: "list.bullet").tag(true)
                }
                .pickerStyle(.segmented).help("Grid or list")
                Menu {
                    Button("Export \(results.count) Results…") { model.export(resources: results, suggestedName: "skilldeck-\(title.lowercased().replacingOccurrences(of: " ", with: "-"))") }
                    if !model.searchText.isEmpty || !filters.isEmpty {
                        Button("Clear Search and Filters") { model.searchText = ""; filters = SearchFilters() }
                    }
                } label: { Label("More", systemImage: "ellipsis.circle") }
            }
        }
    }

    private func icon(for kind: SearchSuggestion.Kind) -> String {
        switch kind {
        case .resource: "doc"
        case .tag: "tag"
        case .useCase: "target"
        case .author: "person"
        case .domain: "folder"
        }
    }
}

struct FilterBar: View {
    @Environment(AppModel.self) private var model
    @Binding var filters: SearchFilters
    var hideType = false

    var body: some View {
        if let index = model.index {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if !hideType {
                        multiMenu("Type", ResourceType.allCases.filter { $0 != .instruction }.map { ($0.rawValue, $0.pluralName) },
                                  selected: Set(filters.types.map(\.rawValue))) { v in toggle(&filters.types, ResourceType(rawValue: v)!) }
                    }
                    multiMenu("Domain", index.catalog.domains.map { ($0.id, $0.name) }, selected: filters.domains) { toggle(&filters.domains, $0) }
                    multiMenu("Use Case", useCases(index).map { ($0, $0.humanized) }, selected: filters.useCases) { toggle(&filters.useCases, $0) }
                    multiMenu("Platform", index.catalog.platforms.map { ($0.id, $0.name) }, selected: filters.platforms) { toggle(&filters.platforms, $0) }
                    Menu(filters.minimumLevel.map { "Compatibility: \($0.displayName)" } ?? "Compatibility") {
                        Button("Any") { filters.minimumLevel = nil }
                        ForEach([CompatibilityLevel.nativeInstall, .nativeImport, .fileExport, .copyPaste], id: \.self) { l in
                            Button("\(l.displayName) or better") { filters.minimumLevel = l }
                        }
                    }
                    .fixedSize()
                    multiMenu("Author", index.catalog.contributors.map { ($0.github.lowercased(), $0.displayName) }, selected: filters.authors) { toggle(&filters.authors, $0) }
                    Picker("Status", selection: $filters.installState) {
                        Text("Any Status").tag(SearchFilters.InstallStateFilter.any)
                        Text("Installed").tag(SearchFilters.InstallStateFilter.installed)
                        Text("Not Installed").tag(SearchFilters.InstallStateFilter.notInstalled)
                    }
                    .fixedSize()
                    Toggle("Featured", isOn: $filters.featuredOnly).toggleStyle(.button)
                    if !filters.isEmpty { Button("Clear") { filters = SearchFilters() }.buttonStyle(.link) }
                }
                .controlSize(.small)
            }
        }
    }

    private func useCases(_ index: CatalogIndex) -> [String] {
        let domains = filters.domains.isEmpty ? index.catalog.domains : index.catalog.domains.filter { filters.domains.contains($0.id) }
        return domains.flatMap(\.useCases)
    }

    private func toggle<T: Hashable>(_ set: inout Set<T>, _ v: T) {
        if set.contains(v) { set.remove(v) } else { set.insert(v) }
    }

    private func multiMenu(_ title: String, _ options: [(String, String)], selected: Set<String>, toggle: @escaping (String) -> Void) -> some View {
        Menu(selected.isEmpty ? title : "\(title) (\(selected.count))") {
            ForEach(options, id: \.0) { id, name in
                Button { toggle(id) } label: {
                    if selected.contains(id) { Label(name, systemImage: "checkmark") } else { Text(name) }
                }
            }
        }
        .fixedSize()
    }
}

// MARK: - Favorites

struct FavoritesView: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        let favs = model.resources(model.library.favorites)
        let recents = model.resources(model.library.recents.map(\.resourceID))
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeader(title: "Favorites", subtitle: "\(favs.count) saved")
                if favs.isEmpty {
                    EmptyStateView(title: "No favorites yet", symbol: "star", message: "Star a resource from its detail page to keep it here.")
                } else { ResourceGrid(resources: favs) }
                if !recents.isEmpty {
                    HStack {
                        SectionHeader(title: "Recently Viewed", subtitle: "Stored only on this Mac")
                        Button("Clear History") { model.clearRecents() }.buttonStyle(.link)
                    }
                    ResourceGrid(resources: Array(recents.prefix(12)))
                }
            }
            .padding(24)
        }
        .navigationTitle("Favorites")
        .toolbar {
            if !favs.isEmpty {
                Button { model.export(resources: favs, suggestedName: "skilldeck-favorites") } label: { Label("Export Favorites", systemImage: "square.and.arrow.up") }
            }
        }
    }
}
