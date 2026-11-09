import SkilldeckCore
import SwiftUI

// MARK: - Collections

struct CollectionCard: View {
    @Environment(AppModel.self) private var model
    let collection: ResourceCollection

    var body: some View {
        Button { model.open(.collection(collection.id)) } label: {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .bottomLeading) {
                    CollectionArtwork(collection: collection).frame(height: 92)
                    Text("\(collection.resources.count) resources").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.9)).padding(10)
                }
                Text(collection.title).font(.headline).lineLimit(1)
                Text(collection.description).font(.callout).foregroundStyle(.secondary).lineLimit(2).multilineTextAlignment(.leading)
            }
            .padding(10)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(.separator.opacity(0.6)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Native, consistent collection artwork: accent gradient, a large symbol, and a subtle grid of type glyphs.
struct CollectionArtwork: View {
    let collection: ResourceCollection
    var body: some View {
        let tint = collection.tint
        RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(LinearGradient(colors: [tint.opacity(0.95), tint.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(alignment: .topTrailing) {
                Image(systemName: collection.symbol)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(12)
            }
            .overlay(alignment: .topLeading) {
                HStack(spacing: 4) {
                    ForEach([ResourceType.agent, .skill, .prompt, .routine], id: \.self) {
                        Image(systemName: $0.symbol).font(.caption2).foregroundStyle(.white.opacity(0.55))
                    }
                }
                .padding(10)
            }
            .accessibilityHidden(true)
    }
}

struct CollectionsView: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeader(title: "Curated Collections", subtitle: "Toolkits assembled from canonical catalog resources")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 14)], spacing: 14) {
                    ForEach(model.index?.catalog.collections ?? []) { CollectionCard(collection: $0) }
                }
                if !model.library.collections.isEmpty {
                    SectionHeader(title: "My Collections", subtitle: "Stored only on this Mac")
                    ForEach(model.library.collections) { c in
                        Button { model.open(.userCollection(c.id)) } label: {
                            Label("\(c.name) — \(c.resourceIDs.count) resources", systemImage: "folder")
                        }
                        .buttonStyle(.link)
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("Collections")
    }
}

struct CollectionDetailView: View {
    @Environment(AppModel.self) private var model
    let collectionID: String

    var body: some View {
        if let index = model.index, let c = index.collectionsByID[collectionID] {
            let resources = index.resources(in: c)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    CollectionArtwork(collection: c).frame(height: 140)
                    Text(c.title).font(.largeTitle.weight(.bold))
                    Text(c.description).font(.title3).foregroundStyle(.secondary)
                    LabeledContent("For") { Text(c.audience) }
                    FlowLayout { ForEach(c.useCases, id: \.self) { TagChip(text: $0.humanized) } }
                    HStack {
                        Button { model.export(resources: resources, suggestedName: c.id) } label: { Label("Export Collection…", systemImage: "square.and.arrow.up") }
                        Button { model.createCollection(c.title, with: resources.map(\.id)); model.show("Copied to My Collections") } label: { Label("Copy to My Collections", systemImage: "folder.badge.plus") }
                    }
                    Divider()
                    Text("Recommended order").font(.headline)
                    VStack(spacing: 8) {
                        ForEach(Array(c.resources.enumerated()), id: \.offset) { _, item in
                            if let r = index.resource(item.id) {
                                Button { model.openResource(r.id) } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        Text(item.step.map { "\($0)" } ?? "•").font(.title3.monospacedDigit().weight(.semibold)).foregroundStyle(c.tint).frame(width: 28)
                                        ResourceRow(resource: r)
                                    }
                                    .padding(10)
                                    .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                                if let note = item.note { Text(note).font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 50) }
                            }
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: 900, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle(c.title)
        } else {
            EmptyStateView(title: "Collection not found", symbol: "rectangle.stack", message: collectionID)
        }
    }
}

struct UserCollectionView: View {
    @Environment(AppModel.self) private var model
    let collectionID: UUID
    @State private var renaming = false
    @State private var name = ""

    var body: some View {
        if let c = model.library.collections.first(where: { $0.id == collectionID }) {
            let resources = model.resources(c.resourceIDs)
            Group {
                if resources.isEmpty {
                    EmptyStateView(title: "Empty collection", symbol: "folder", message: "Use “Add to Collection” on any resource.")
                } else {
                    List {
                        ForEach(resources) { r in
                            Button { model.openResource(r.id) } label: { ResourceRow(resource: r) }.buttonStyle(.plain)
                                .contextMenu { Button("Remove from Collection") { model.removeFromCollection(c.id, r.id) } }
                        }
                    }
                }
            }
            .navigationTitle(c.name)
            .toolbar {
                Button { name = c.name; renaming = true } label: { Label("Rename", systemImage: "pencil") }
                Button { model.export(resources: resources, suggestedName: c.name) } label: { Label("Export", systemImage: "square.and.arrow.up") }
                    .disabled(resources.isEmpty)
            }
            .alert("Rename Collection", isPresented: $renaming) {
                TextField("Name", text: $name)
                Button("Rename") { if !name.isEmpty { model.renameCollection(c.id, name) } }
                Button("Cancel", role: .cancel) {}
            }
        } else {
            EmptyStateView(title: "Collection deleted", symbol: "folder.badge.minus", message: "")
        }
    }
}

// MARK: - Contributors

struct ContributorCard: View {
    @Environment(AppModel.self) private var model
    let contributor: Contributor

    var body: some View {
        Button { model.open(.contributor(contributor.id)) } label: {
            HStack(spacing: 12) {
                AvatarView(login: contributor.github, name: contributor.displayName, size: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(contributor.displayName).font(.headline)
                    Text("@\(contributor.github)").font(.callout).foregroundStyle(.secondary)
                    Text("\(contributor.resourceCount) published resource\(contributor.resourceCount == 1 ? "" : "s")").font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(.separator.opacity(0.6)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ContributorsView: View {
    @Environment(AppModel.self) private var model
    @State private var query = ""
    @State private var sort = "count"
    @State private var typeFilter: ResourceType?
    @State private var domainFilter: String?

    var body: some View {
        let list = filtered()
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Picker("Sort", selection: $sort) {
                        Text("Most Resources").tag("count")
                        Text("Recently Active").tag("recent")
                        Text("Name").tag("name")
                    }
                    .fixedSize()
                    Picker("Type", selection: $typeFilter) {
                        Text("Any Type").tag(ResourceType?.none)
                        ForEach([ResourceType.agent, .skill, .prompt, .routine], id: \.self) { Text($0.pluralName).tag(Optional($0)) }
                    }
                    .fixedSize()
                    Picker("Domain", selection: $domainFilter) {
                        Text("Any Domain").tag(String?.none)
                        ForEach(model.index?.catalog.domains ?? []) { Text($0.name).tag(Optional($0.id)) }
                    }
                    .fixedSize()
                    Spacer()
                }
                .controlSize(.small)
                if list.isEmpty {
                    EmptyStateView(title: "No contributors match", symbol: "person.2.slash", message: "Clear the search or filters.")
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 12)], spacing: 12) {
                        ForEach(list) { ContributorCard(contributor: $0) }
                    }
                }
                Text("Contributors are derived from the author of each approved resource. Want to appear here? Submit a resource on GitHub.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .navigationTitle("Contributors")
        .searchable(text: $query, placement: .toolbar, prompt: "Search contributors")
    }

    private func filtered() -> [Contributor] {
        var list = model.index?.catalog.contributors ?? []
        let q = query.lowercased()
        if !q.isEmpty { list = list.filter { $0.github.lowercased().contains(q) || $0.displayName.lowercased().contains(q) } }
        if let t = typeFilter { list = list.filter { ($0.countsByType[t.rawValue] ?? 0) > 0 } }
        if let d = domainFilter { list = list.filter { $0.domains.contains(d) } }
        switch sort {
        case "recent": list.sort { ($0.lastUpdated ?? "", $1.github) > ($1.lastUpdated ?? "", $0.github) }
        case "name": list.sort { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
        default: list.sort { ($0.resourceCount, $1.github) > ($1.resourceCount, $0.github) }
        }
        return list
    }
}

struct ContributorProfileView: View {
    @Environment(AppModel.self) private var model
    let login: String
    @State private var typeFilter: ResourceType?

    var body: some View {
        if let index = model.index, let c = index.contributor(login) {
            let profile = model.profiles[c.id]
            let resources = index.resources(by: c).filter { typeFilter == nil || $0.type == typeFilter }
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 20) {
                        AvatarView(login: c.github, name: c.displayName, size: 112)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(profile?.name ?? c.displayName).font(.largeTitle.weight(.bold))
                            Text("@\(c.github)").font(.title3).foregroundStyle(.secondary)
                            if let bio = c.bio ?? profile?.bio { Text(bio).font(.body).fixedSize(horizontal: false, vertical: true).padding(.top, 4) }
                            HStack(spacing: 14) {
                                Button { model.openURL(c.profileUrl) } label: { Label("GitHub Profile", systemImage: "link") }.buttonStyle(.link)
                                if let site = c.website ?? profile?.blog, URLSafety.safeWebURL(site) != nil {
                                    Button { model.openURL(site) } label: { Label(URL(string: site)?.host ?? site, systemImage: "globe") }.buttonStyle(.link)
                                }
                                if let loc = c.location ?? profile?.location { Label(loc, systemImage: "mappin.and.ellipse").foregroundStyle(.secondary) }
                                ForEach(c.socialLinks, id: \.url) { s in Button(s.label) { model.openURL(s.url) }.buttonStyle(.link) }
                            }
                            .font(.callout)
                            .padding(.top, 4)
                        }
                    }
                    stats(c)
                    let featured = model.resources(c.featuredResourceIds)
                    if !featured.isEmpty {
                        SectionHeader(title: "Featured by \(c.displayName)")
                        ResourceGrid(resources: featured)
                    }
                    HStack {
                        SectionHeader(title: "Published Resources", subtitle: "\(resources.count) shown")
                        Picker("Type", selection: $typeFilter) {
                            Text("All").tag(ResourceType?.none)
                            ForEach([ResourceType.agent, .skill, .prompt, .routine], id: \.self) { Text($0.pluralName).tag(Optional($0)) }
                        }
                        .pickerStyle(.segmented).fixedSize()
                    }
                    ResourceGrid(resources: resources.sorted { ($0.type.rawValue, $0.name) < ($1.type.rawValue, $1.name) })
                    if profile == nil {
                        Text(model.fetchGitHubProfiles ? "Showing catalog attribution; live GitHub details load when online." : "GitHub profile fetching is off in Settings; showing catalog attribution.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(24)
            }
            .navigationTitle(c.displayName)
            .task(id: c.id) { await model.loadProfile(c.github) }
        } else {
            EmptyStateView(title: "Contributor not found", symbol: "person.crop.circle.badge.questionmark", message: "@\(login) has no approved resources in this catalog.")
        }
    }

    private func stats(_ c: Contributor) -> some View {
        HStack(spacing: 0) {
            stat("\(c.resourceCount)", "Resources")
            ForEach([ResourceType.agent, .skill, .prompt, .routine], id: \.self) { t in
                Divider().frame(height: 36)
                stat("\(c.countsByType[t.rawValue] ?? 0)", t.pluralName)
            }
            Divider().frame(height: 36)
            stat("\(c.domains.count)", "Domains")
        }
        .padding(.vertical, 10)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.title2.weight(.semibold).monospacedDigit())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
