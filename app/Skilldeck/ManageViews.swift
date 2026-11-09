import SkilldeckCore
import SwiftUI

// MARK: - Installed

struct InstalledView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmUninstall: InstallRecord?

    var body: some View {
        let records = model.library.installs.sorted { $0.installedAt > $1.installedAt }
        Group {
            if records.isEmpty {
                EmptyStateView(title: "Nothing installed yet", symbol: "externaldrive", message: "Open a resource and choose Install… to add it to Claude Code, Codex, or a folder you pick.")
            } else {
                Table(records) {
                    TableColumn("Resource") { r in
                        Button { model.openResource(r.resourceID) } label: {
                            HStack { TypeIcon(type: r.resourceType, size: 20); Text(r.resourceName) }
                        }
                        .buttonStyle(.plain)
                    }
                    .width(min: 180, ideal: 240)
                    TableColumn("Target") { r in Text(model.index?.platformsByID[r.platform]?.name ?? r.platform) }.width(110)
                    TableColumn("Version") { r in
                        HStack(spacing: 4) {
                            Text(r.version).monospacedDigit()
                            if let newer = model.updateAvailable(r) { Text("→ \(newer.version)").foregroundStyle(.orange).monospacedDigit() }
                        }
                    }
                    .width(90)
                    TableColumn("Location") { r in
                        Text(r.location.replacingOccurrences(of: FileManager.default.homeDirectoryForCurrentUser.path, with: "~"))
                            .font(.caption.monospaced()).lineLimit(1).truncationMode(.middle).help(r.location)
                    }
                    TableColumn("Installed") { r in Text(r.installedAt, style: .date) }.width(90)
                    TableColumn("") { r in
                        HStack {
                            Button("Reveal") { model.reveal(r.location) }
                            Menu("More") {
                                if model.updateAvailable(r) != nil { Button("Update") { update(r) } }
                                Button("Reinstall") { reinstall(r) }
                                Button("Export…") { if let res = model.index?.resource(r.resourceID) { model.export(resources: [res], suggestedName: res.id) } }
                                Divider()
                                Button("Uninstall…", role: .destructive) { confirmUninstall = r }
                            }
                            .fixedSize()
                        }
                        .controlSize(.small)
                    }
                    .width(150)
                }
            }
        }
        .navigationTitle("Installed")
        .navigationSubtitle("\(records.count) installation\(records.count == 1 ? "" : "s")")
        .confirmationDialog("Uninstall \(confirmUninstall?.resourceName ?? "")?", isPresented: Binding(get: { confirmUninstall != nil }, set: { if !$0 { confirmUninstall = nil } }), presenting: confirmUninstall) { rec in
            let modified = model.modifiedFiles(rec)
            Button(modified.isEmpty ? "Move to Trash" : "Remove Unmodified Files", role: .destructive) { model.uninstall(rec) }
            if !modified.isEmpty { Button("Remove All, Including My Changes", role: .destructive) { model.uninstall(rec, force: true) } }
            Button("Cancel", role: .cancel) {}
        } message: { rec in
            let modified = model.modifiedFiles(rec)
            Text(modified.isEmpty ? "\(rec.files.count) file(s) Skilldeck installed will be moved to the Trash." : "\(modified.count) file(s) were changed since installation and are kept unless you choose otherwise.")
        }
    }

    private func update(_ r: InstallRecord) {
        do {
            try model.updateInstalled(r, allowOverwriteModified: false)
            model.show("Updated \(r.resourceName)")
        } catch InstallError.conflictsUnresolved {
            model.show("\(r.resourceName) has local changes. Use Updates to review before replacing.", error: true)
        } catch { model.show(error.localizedDescription, error: true) }
    }

    private func reinstall(_ r: InstallRecord) {
        do { try model.updateInstalled(r, allowOverwriteModified: false); model.show("Reinstalled \(r.resourceName)") }
        catch { model.show(error.localizedDescription, error: true) }
    }
}

// MARK: - Updates

struct UpdatesView: View {
    @Environment(AppModel.self) private var model
    @State private var reviewing: InstallRecord?

    var body: some View {
        Form {
            Section("Catalog") {
                if let index = model.index {
                    LabeledContent("Installed catalog") {
                        Text("\(index.catalog.catalogVersion) · \(model.catalogSource == .bundled ? "bundled with app" : "downloaded") · \(index.resources.count) resources")
                    }
                    LabeledContent("Generated", value: index.catalog.generatedAt)
                }
                if !model.quarantined.isEmpty {
                    Label("\(model.quarantined.count) resource(s) failed integrity verification and are hidden: \(model.quarantined.joined(separator: ", "))", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
                if let check = model.updateCheck {
                    if check.isNewer {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Catalog \(check.pointer.catalogVersion) is available", systemImage: "arrow.down.circle.fill").font(.headline).foregroundStyle(.blue)
                            Text("\(check.added.count) added · \(check.updated.count) updated · \(check.removed.count) removed in this release · \(check.pointer.bundle.size.formatted(.byteCount(style: .file)))")
                                .font(.callout).foregroundStyle(.secondary)
                            changeList("Added", check.added)
                            changeList("Updated", check.updated)
                            changeList("Removed", check.removed)
                            HStack {
                                Button(model.isApplyingUpdate ? "Updating…" : "Download and Install") { Task { await model.applyCatalogUpdate() } }
                                    .buttonStyle(.borderedProminent).disabled(model.isApplyingUpdate)
                                if let notes = check.pointer.releaseNotesUrl { Button("Release Notes") { model.openURL(notes) }.buttonStyle(.link) }
                            }
                            Text("The download is verified against its published SHA-256 before it replaces your catalog. Installed resources are never changed automatically.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    } else {
                        Label("Your catalog is up to date.", systemImage: "checkmark.circle").foregroundStyle(.green)
                    }
                }
                if let err = model.updateError { Label(err, systemImage: "wifi.exclamationmark").foregroundStyle(.red).textSelection(.enabled) }
                HStack {
                    Button(model.isCheckingUpdates ? "Checking…" : "Check Now") { Task { await model.checkForUpdates(userInitiated: true) } }
                        .disabled(model.isCheckingUpdates)
                    if model.catalogStore.canRollback { Button("Roll Back to Previous Catalog") { model.rollbackCatalog() } }
                    if model.catalogSource == .downloaded { Button("Use Bundled Catalog") { model.resetCatalogToBundled() } }
                    Spacer()
                    if let d = model.lastUpdateCheck { Text("Last checked \(d.formatted(.relative(presentation: .named)))").font(.caption).foregroundStyle(.secondary) }
                }
            }

            Section("Installed resources with updates") {
                let pending = model.installsWithUpdates
                if pending.isEmpty {
                    Text("All installed resources match the catalog.").foregroundStyle(.secondary)
                } else {
                    ForEach(pending, id: \.0.id) { rec, res in
                        HStack {
                            TypeIcon(type: res.type, size: 22)
                            VStack(alignment: .leading) {
                                Text(res.name)
                                Text("\(rec.version) → \(res.version) · \(model.index?.platformsByID[rec.platform]?.name ?? rec.platform)").font(.caption).foregroundStyle(.secondary)
                                if let note = res.changelog?.first { Text(note).font(.caption).foregroundStyle(.secondary) }
                            }
                            Spacer()
                            let modified = model.modifiedFiles(rec)
                            if !modified.isEmpty { Label("Locally modified", systemImage: "pencil.circle").font(.caption).foregroundStyle(.orange) }
                            Button("Review…") { reviewing = rec }
                        }
                    }
                }
            }

            Section("History") {
                if model.library.updateHistory.isEmpty {
                    Text("No updates yet.").foregroundStyle(.secondary)
                } else {
                    ForEach(model.library.updateHistory.prefix(30)) { h in
                        HStack {
                            Text(h.date, style: .date).foregroundStyle(.secondary).frame(width: 100, alignment: .leading)
                            Text("\(h.kind.capitalized): \(h.fromVersion ?? "—") → \(h.toVersion)")
                            Text(h.summary).foregroundStyle(.secondary)
                        }
                        .font(.callout)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Updates")
        .sheet(item: $reviewing) { rec in UpdateReviewSheet(record: rec).environment(model) }
    }

    @ViewBuilder private func changeList(_ title: String, _ ids: [String]) -> some View {
        if !ids.isEmpty {
            DisclosureGroup("\(title) (\(ids.count))") {
                Text(ids.map { model.index?.resource($0)?.name ?? $0 }.joined(separator: ", ")).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct UpdateReviewSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let record: InstallRecord
    @State private var error: String?

    var body: some View {
        let modified = model.modifiedFiles(record)
        let res = model.index?.resource(record.resourceID)
        VStack(alignment: .leading, spacing: 14) {
            Text("Update \(record.resourceName)").font(.title2.weight(.semibold))
            Text("Installed \(record.version) → available \(res?.version ?? "?")").foregroundStyle(.secondary)
            if let log = res?.changelog, !log.isEmpty {
                VStack(alignment: .leading) { ForEach(log, id: \.self) { Text("• \($0)").font(.callout) } }
            }
            if modified.isEmpty {
                Label("Installed files are unchanged since installation; they will be replaced in place.", systemImage: "checkmark.circle").foregroundStyle(.green)
            } else {
                Label("You changed \(modified.count) installed file(s):", systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                ForEach(modified, id: \.self) { Text($0).font(.caption.monospaced()) }
                Text("Updating backs these up to Skilldeck's Backups folder before replacing them.").font(.callout)
            }
            if let error { Text(error).foregroundStyle(.red) }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }.keyboardShortcut(.cancelAction)
                Button(modified.isEmpty ? "Update" : "Back Up and Update") {
                    do {
                        try model.updateInstalled(record, allowOverwriteModified: !modified.isEmpty)
                        model.show("Updated \(record.resourceName)")
                        dismiss()
                    } catch { self.error = error.localizedDescription }
                }
                .buttonStyle(.borderedProminent).keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 540)
    }
}

// MARK: - Settings

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @AppStorage("catalogEndpoint") private var endpoint = UpdateService.defaultEndpoint
    @AppStorage("autoCheckUpdates") private var autoCheck = true
    @AppStorage("fetchGitHubProfiles") private var fetchProfiles = true
    @AppStorage("defaultPlatform") private var defaultPlatform = "claude-code"
    @AppStorage("projectFolder") private var projectFolder = ""
    @AppStorage("customInstallFolder") private var customFolder = ""
    @AppStorage("appearance") private var appearance = "system"
    @State private var confirmReset = false

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $appearance) {
                    Text("System").tag("system"); Text("Light").tag("light"); Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
                .onChange(of: appearance) { applyAppearance() }
                .onAppear { applyAppearance() }
            }
            Section("Catalog source") {
                TextField("Release endpoint (latest.json)", text: $endpoint)
                    .font(.callout.monospaced())
                if URLSafety.safeWebURL(endpoint) == nil { Text("Must be an https:// URL.").font(.caption).foregroundStyle(.red) }
                Button("Restore Default Endpoint") { endpoint = UpdateService.defaultEndpoint }.buttonStyle(.link)
                Text("Skilldeck works fully offline with the catalog bundled in the app. The endpoint is only used to check for newer versions.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Updates & privacy") {
                Toggle("Check for catalog updates at launch", isOn: $autoCheck)
                Toggle("Load public GitHub profiles and avatars for contributors", isOn: $fetchProfiles)
                Text("No account, API key, or telemetry. Network requests go only to the catalog endpoint and github.com.").font(.caption).foregroundStyle(.secondary)
            }
            Section("Installation destinations") {
                Picker("Preferred target", selection: $defaultPlatform) {
                    ForEach(model.index?.catalog.platforms ?? []) { Text($0.name).tag($0.id) }
                }
                folder("Default project folder", $projectFolder)
                folder("Default custom directory", $customFolder)
            }
            Section("Compatibility registry") {
                ForEach(model.index?.catalog.platforms ?? []) { p in
                    DisclosureGroup("\(p.name)\(p.verifiedOn.map { " · verified \($0)" } ?? "")") {
                        ForEach(p.targets, id: \.resourceType) { t in
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(t.resourceType.pluralName): \(t.level.displayName) — \(t.format)").font(.callout)
                                if let u = t.userPath { Text(u).font(.caption.monospaced()).foregroundStyle(.secondary) }
                                if let l = t.limitations { Text(l).font(.caption).foregroundStyle(.secondary) }
                            }
                        }
                        if let doc = p.documentation { Button("Documentation") { model.openURL(doc) }.buttonStyle(.link) }
                    }
                }
            }
            Section("Local data") {
                LabeledContent("Data folder") {
                    Button(model.paths.root.path) { model.reveal(model.paths.root.path) }.buttonStyle(.link).lineLimit(1).truncationMode(.middle)
                }
                Button("Clear Recently Viewed") { model.clearRecents() }
                Button("Reset Favorites, Collections, and Install Records…", role: .destructive) { confirmReset = true }
            }
            Section("About Skilldeck") {
                LabeledContent("Version", value: model.appVersion)
                LabeledContent("Catalog", value: model.index.map { "\($0.catalog.catalogVersion) (\($0.resources.count) resources)" } ?? "—")
                Button("Source Code on GitHub") { model.openURL("https://github.com/seyhunak/skilldeck") }.buttonStyle(.link)
                Text("Proudly powered by Claude. Open source under the MIT License. Catalog resources carry their own licenses, shown on each resource.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Open-source licenses") {
                Text("Skilldeck uses only Apple system frameworks (SwiftUI, Foundation, CryptoKit, AppKit). The catalog tooling uses PyYAML (MIT) and jsonschema (MIT). Resource content is MIT-licensed unless stated otherwise in its manifest.")
                    .font(.callout).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .confirmationDialog("Reset local data?", isPresented: $confirmReset) {
            Button("Reset", role: .destructive) { model.resetLocalData() }
        } message: {
            Text("Favorites, history, personal collections, and install records are removed. Installed files on disk are not deleted.")
        }
    }

    private func folder(_ label: String, _ binding: Binding<String>) -> some View {
        LabeledContent(label) {
            HStack {
                Text(binding.wrappedValue.isEmpty ? "None" : binding.wrappedValue).font(.caption.monospaced()).lineLimit(1).truncationMode(.middle)
                Button("Choose…") {
                    let p = NSOpenPanel(); p.canChooseDirectories = true; p.canChooseFiles = false; p.canCreateDirectories = true
                    if p.runModal() == .OK, let u = p.url { binding.wrappedValue = u.path }
                }
                if !binding.wrappedValue.isEmpty { Button("Clear") { binding.wrappedValue = "" } }
            }
        }
    }

    private func applyAppearance() {
        NSApp.appearance = switch appearance {
        case "light": NSAppearance(named: .aqua)
        case "dark": NSAppearance(named: .darkAqua)
        default: nil
        }
    }
}
