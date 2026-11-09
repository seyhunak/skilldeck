import SkilldeckCore
import SwiftUI

struct ResourceDetailView: View {
    @Environment(AppModel.self) private var model
    let resourceID: String
    @State private var tab: String = "Overview"
    @State private var showInstall = false

    var body: some View {
        if let index = model.index, let r = index.resource(resourceID) {
            let tabs = tabsFor(r)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header(r, index)
                    Picker("Section", selection: $tab) { ForEach(tabs, id: \.self) { Text($0) } }
                        .pickerStyle(.segmented).labelsHidden()
                    tabContent(r, index)
                }
                .padding(24)
                .frame(maxWidth: 980, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle(r.name)
            .navigationSubtitle("\(r.type.displayName) · v\(r.version)")
            .toolbar { toolbar(r) }
            .sheet(isPresented: $showInstall) { InstallSheet(resource: r).environment(model) }
            .onAppear { model.recordView(r.id); if !tabs.contains(tab) { tab = "Overview" } }
        } else {
            EmptyStateView(title: "Resource not found", symbol: "questionmark.folder", message: "“\(resourceID)” is not in the current catalog. It may have been removed in an update.")
        }
    }

    // MARK: Header

    private func header(_ r: Resource, _ index: CatalogIndex) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                TypeIcon(type: r.type, size: 56)
                VStack(alignment: .leading, spacing: 6) {
                    Text(r.name).font(.largeTitle.weight(.bold)).textSelection(.enabled)
                    HStack(spacing: 8) {
                        TypeBadge(type: r.type)
                        Text(index.domainName(r.domain)).font(.callout).foregroundStyle(.secondary)
                        if r.featured { Label("Featured", systemImage: "star.fill").font(.caption).foregroundStyle(.yellow) }
                    }
                    Text(r.description).font(.title3).foregroundStyle(.secondary).textSelection(.enabled).fixedSize(horizontal: false, vertical: true)
                }
            }
            HStack(spacing: 10) {
                Button { showInstall = true } label: {
                    Label(model.installedIDs.contains(r.id) ? "Install Again…" : "Install…", systemImage: "arrow.down.to.line")
                }
                .buttonStyle(.borderedProminent).controlSize(.large)
                Button { model.copyToPasteboard(model.primaryContent(r), label: r.type == .prompt ? "prompt" : "\(r.type.displayName.lowercased()) content") } label: {
                    Label(copyLabel(r), systemImage: "doc.on.doc")
                }
                .controlSize(.large)
                Button { model.toggleFavorite(r.id) } label: {
                    Label(model.isFavorite(r.id) ? "Favorited" : "Favorite", systemImage: model.isFavorite(r.id) ? "star.fill" : "star")
                }
                .controlSize(.large)
                Spacer()
                AuthorButton(author: r.author)
            }
            let installs = model.installs(for: r.id)
            if !installs.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(installs) { rec in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text("Installed v\(rec.version) for \(index.platformsByID[rec.platform]?.name ?? rec.platform)").font(.callout)
                            Text(rec.location).font(.caption.monospaced()).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                            Button("Reveal") { model.reveal(rec.location) }.buttonStyle(.link)
                            if model.updateAvailable(rec) != nil { Text("Update available").font(.caption.weight(.semibold)).foregroundStyle(.orange) }
                        }
                    }
                }
                .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            }
            if r.safety.professionalAdviceDisclaimer == true || r.safety.handlesSensitiveData == true {
                Label(r.safety.notes ?? "Handles sensitive data; review outputs before acting.", systemImage: "exclamationmark.shield")
                    .font(.callout).foregroundStyle(.secondary)
                    .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                    .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func copyLabel(_ r: Resource) -> String {
        switch r.type {
        case .agent: "Copy Agent"
        case .skill: "Copy SKILL.md"
        case .prompt: "Copy Prompt"
        case .routine: "Copy Routine"
        case .instruction: "Copy"
        }
    }

    @ToolbarContentBuilder
    private func toolbar(_ r: Resource) -> some ToolbarContent {
        ToolbarItemGroup {
            Menu {
                Button("Copy Full \(r.entrypoint)") { model.copyToPasteboard(r.entrypointContent, label: r.entrypoint) }
                if let index = model.index {
                    Button("Copy Installation Instructions") { model.copyToPasteboard(Installer.instructions(for: r, in: index), label: "installation instructions") }
                }
                Divider()
                Button("Export Package as ZIP…") { model.export(resources: [r], suggestedName: "\(r.id)-\(r.version)") }
                if r.type == .agent { Button("Export as AGENTS.md Section (Codex)…") { model.exportAgentsMarkdown(r) } }
                if r.type == .skill { Button("Export ZIP for Claude Desktop Upload…") { model.export(resources: [r], suggestedName: r.id) } }
                if !model.library.collections.isEmpty {
                    Divider()
                    Menu("Add to Collection") {
                        ForEach(model.library.collections) { c in Button(c.name) { model.addToCollection(c.id, r.id) } }
                    }
                }
                Divider()
                Button("View Source on GitHub") { model.openURL("\(model.index?.catalog.repository ?? "")/tree/main/\(r.sourcePath ?? "")") }
            } label: { Label("Share & Export", systemImage: "square.and.arrow.up") }
        }
    }

    // MARK: Tabs

    private func tabsFor(_ r: Resource) -> [String] {
        var t = ["Overview"]
        switch r.type {
        case .agent: t += ["Instructions", "System Prompt"]
        case .skill: t += ["SKILL.md"]
        case .prompt: t += ["Prompt"]
        case .routine: t += ["Workflow"]
        case .instruction: t += ["Instructions"]
        }
        if r.files.count > 2 { t.append("Files") }
        t.append("Install")
        return t
    }

    @ViewBuilder
    private func tabContent(_ r: Resource, _ index: CatalogIndex) -> some View {
        let content = r.entrypointContent
        switch tab {
        case "Instructions", "SKILL.md", "Workflow":
            MarkdownView(text: content)
        case "System Prompt":
            VStack(alignment: .leading, spacing: 10) {
                Text("The complete agent definition — this file is what Skilldeck installs as a Claude Code subagent.").font(.callout).foregroundStyle(.secondary)
                CodePanel(text: content) { model.copyToPasteboard(content, label: "system prompt") }
            }
        case "Prompt":
            PromptPanel(resource: r)
        case "Files":
            FilesPanel(resource: r)
        case "Install":
            CompatibilityPanel(resource: r, index: index) { showInstall = true }
        default:
            OverviewPanel(resource: r, index: index)
        }
    }
}

// MARK: - Panels

struct OverviewPanel: View {
    @Environment(AppModel.self) private var model
    let resource: Resource
    let index: CatalogIndex

    var body: some View {
        let r = resource
        let sections = Markdown.sections(r.entrypointContent)
        VStack(alignment: .leading, spacing: 22) {
            if let purpose = r.purpose { block("Purpose") { Text(purpose).textSelection(.enabled) } }
            highlights(r, sections)
            block("Details") {
                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 6) {
                    meta("Version", r.version)
                    meta("License", r.license)
                    meta("Domain", index.domainName(r.domain))
                    meta("Use cases", r.useCases.map(\.humanized).joined(separator: ", "))
                    meta("Last updated", r.updated ?? "—")
                    meta("Created", r.created ?? "—")
                    meta("Package", "\(r.files.count) file\(r.files.count == 1 ? "" : "s") · SHA-256 \(r.contentSha256.prefix(12))…")
                    if let changes = r.changelog, let latest = changes.first { meta("Changelog", latest) }
                }
                .font(.callout)
            }
            block("Tags") { FlowLayout { ForEach(r.tags, id: \.self) { TagChip(text: $0) } } }
            let deps = model.resources(r.dependencies)
            if !deps.isEmpty { block(r.type == .agent ? "Supporting Skills & Dependencies" : "Dependencies") { ResourceGrid(resources: deps) } }
            let related = index.relatedResources(for: r).filter { !r.dependencies.contains($0.id) }
            if !related.isEmpty { block("Related Resources") { ResourceGrid(resources: Array(related.prefix(9))) } }
            let cols = r.collections.compactMap { index.collectionsByID[$0] }
            if !cols.isEmpty {
                block("In Collections") {
                    FlowLayout {
                        ForEach(cols) { c in
                            Button { model.open(.collection(c.id)) } label: { Label(c.title, systemImage: c.symbol) }.buttonStyle(.bordered)
                        }
                    }
                }
            }
            if let c = index.contributor(r.author.github) {
                block("Author") { ContributorCard(contributor: c).frame(maxWidth: 360) }
            }
        }
    }

    /// Type-specific quick view of the most important sections.
    @ViewBuilder
    private func highlights(_ r: Resource, _ sections: [MarkdownSection]) -> some View {
        let wanted: [String] = switch r.type {
        case .agent: ["When to use", "Required inputs", "Expected output", "Limitations", "Safety boundaries"]
        case .skill: ["When to use", "Inputs", "Expected output", "Constraints"]
        case .prompt: ["Intended task", "Required context", "Output format"]
        case .routine: ["Objective", "Trigger", "Prerequisites", "Human approval"]
        case .instruction: ["Scope"]
        }
        ForEach(wanted, id: \.self) { w in
            if let s = sections.first(where: { $0.title.lowercased().hasPrefix(w.lowercased()) }) {
                block(s.title) { MarkdownView(text: s.body) }
            }
        }
    }

    private func block<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content()
        }
    }

    private func meta(_ k: String, _ v: String) -> some View {
        GridRow {
            Text(k).foregroundStyle(.secondary)
            Text(v).textSelection(.enabled)
        }
    }
}

struct CodePanel: View {
    let text: String
    var copy: () -> Void
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(.horizontal) {
                Text(text).font(.system(.callout, design: .monospaced)).textSelection(.enabled).padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.separator))
            Button(action: copy) { Label("Copy", systemImage: "doc.on.doc") }.padding(8)
        }
    }
}

struct PromptPanel: View {
    @Environment(AppModel.self) private var model
    let resource: Resource
    @State private var values: [String: String] = [:]

    var body: some View {
        let content = resource.entrypointContent
        let prompt = Markdown.promptText(content) ?? content
        let vars = Markdown.placeholders(prompt)
        VStack(alignment: .leading, spacing: 18) {
            CodePanel(text: prompt) { model.copyToPasteboard(prompt, label: "prompt") }
            if !vars.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fill in placeholders").font(.headline)
                    Text("Optional: values stay on this Mac and are only used to build the copied text.").font(.caption).foregroundStyle(.secondary)
                    ForEach(vars, id: \.self) { v in
                        HStack(alignment: .top) {
                            Text("{{\(v)}}").font(.callout.monospaced()).frame(width: 220, alignment: .leading)
                            TextField(v.humanized.lowercased(), text: Binding(get: { values[v, default: ""] }, set: { values[v] = $0 }), axis: .vertical)
                                .lineLimit(1...6)
                        }
                    }
                    Button { model.copyToPasteboard(filled(prompt), label: "filled prompt") } label: { Label("Copy Filled Prompt", systemImage: "doc.on.clipboard") }
                        .buttonStyle(.borderedProminent)
                }
                .padding(14)
                .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
            }
            ForEach(Markdown.sections(content).filter { !$0.title.lowercased().hasPrefix("prompt") }) { s in
                VStack(alignment: .leading, spacing: 6) {
                    Text(s.title).font(.headline)
                    MarkdownView(text: s.body)
                }
            }
        }
    }

    private func filled(_ prompt: String) -> String {
        var out = prompt
        for (k, v) in values where !v.trimmingCharacters(in: .whitespaces).isEmpty {
            out = out.replacingOccurrences(of: "{{\(k)}}", with: v).replacingOccurrences(of: "{{ \(k) }}", with: v)
        }
        return out
    }
}

struct FilesPanel: View {
    @Environment(AppModel.self) private var model
    let resource: Resource
    @State private var selected: String?

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            List(resource.files, id: \.path, selection: $selected) { f in
                VStack(alignment: .leading) {
                    Text(f.path).font(.callout.monospaced())
                    Text("\(f.size.formatted(.byteCount(style: .file))) · \(f.sha256.prefix(10))…").font(.caption2).foregroundStyle(.secondary)
                }
                .tag(f.path)
            }
            .frame(width: 260, height: 300)
            if let path = selected ?? resource.files.first?.path, let f = resource.file(path) {
                VStack(alignment: .leading) {
                    if f.path.hasSuffix(".md") { MarkdownView(text: f.content ?? "") }
                    else { CodePanel(text: f.content ?? "") { model.copyToPasteboard(f.content ?? "", label: f.path) } }
                }
            }
        }
    }
}

struct CompatibilityPanel: View {
    let resource: Resource
    let index: CatalogIndex
    var install: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Skilldeck installs using each tool's documented format and location. Claims come from the catalog's compatibility registry and the resource manifest.")
                .font(.callout).foregroundStyle(.secondary)
            ForEach(index.catalog.platforms) { p in
                if let c = resource.compatibility(for: p.id) {
                    let t = p.target(for: resource.type)
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: c.level >= .nativeImport ? "checkmark.seal.fill" : c.level >= .copyPaste ? "square.and.arrow.up" : "xmark.circle")
                            .foregroundStyle(c.level >= .nativeImport ? .green : .secondary).frame(width: 20)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(p.name) — \(c.level.displayName)").font(.headline)
                            if let t {
                                Text(t.format).font(.callout)
                                if let u = t.userPath { Text(u.replacingOccurrences(of: "{id}", with: resource.id)).font(.caption.monospaced()).foregroundStyle(.secondary) }
                                if let l = t.limitations { Text(l).font(.caption).foregroundStyle(.secondary) }
                            }
                            if let v = p.verifiedOn { Text("Registry verified \(v)").font(.caption2).foregroundStyle(.tertiary) }
                        }
                    }
                }
            }
            Button("Install…", action: install).buttonStyle(.borderedProminent)
        }
    }
}
