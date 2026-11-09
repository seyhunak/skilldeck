import AppKit
import Observation
import SkilldeckCore
import SwiftUI

enum SidebarItem: Hashable {
    case discover, all
    case type(ResourceType)
    case collections, contributors, installed, updates, favorites, settings
    case userCollection(UUID)
}

enum Route: Hashable {
    case resource(String)
    case contributor(String)
    case collection(String)
    case userCollection(UUID)
}

struct Toast: Identifiable, Equatable {
    let id = UUID()
    var message: String
    var isError = false
}

@MainActor
@Observable
final class AppModel {
    // Catalog
    private(set) var index: CatalogIndex?
    private(set) var search: SearchEngine?
    private(set) var catalogSource: CatalogSource = .bundled
    private(set) var quarantined: [String] = []
    private(set) var loadError: String?

    // User library (mirrors LibraryStore.state for observation)
    private(set) var library = LibraryState()

    // Navigation
    var selection: SidebarItem? = .discover
    var path: [Route] = []
    var searchText = ""
    var searchFocusRequest = 0
    var toast: Toast?

    // Updates
    var updateCheck: CatalogUpdateCheck?
    var isCheckingUpdates = false
    var isApplyingUpdate = false
    var updateError: String?
    var lastUpdateCheck: Date?
    /// Resources added by catalog updates that the user hasn't dismissed yet.
    var newResourceIDs: [String] = UserDefaults.standard.stringArray(forKey: "newResourceIDs") ?? [] {
        didSet { UserDefaults.standard.set(newResourceIDs, forKey: "newResourceIDs") }
    }

    // Contributors
    var profiles: [String: GitHubProfile] = [:]

    let paths: AppPaths
    let store: LibraryStore
    let catalogStore: CatalogStore
    let installer: Installer
    let github: GitHubProfileService
    let appVersion: String

    @ObservationIgnored @AppStorage("catalogEndpoint") var catalogEndpoint = UpdateService.defaultEndpoint
    @ObservationIgnored @AppStorage("autoCheckUpdates") var autoCheckUpdates = true
    @ObservationIgnored @AppStorage("autoInstallCatalogUpdates") var autoInstallCatalogUpdates = true
    @ObservationIgnored @AppStorage("updateCheckIntervalHours") var updateCheckIntervalHours = 6
    @ObservationIgnored @AppStorage("fetchGitHubProfiles") var fetchGitHubProfiles = true
    @ObservationIgnored @AppStorage("defaultPlatform") var defaultPlatform = "claude-code"
    @ObservationIgnored @AppStorage("projectFolder") var projectFolder = ""
    @ObservationIgnored @AppStorage("customInstallFolder") var customInstallFolder = ""

    init(paths: AppPaths = .default) {
        self.paths = paths
        appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        store = LibraryStore(url: paths.libraryFile)
        catalogStore = CatalogStore(paths: paths, bundledURL: Bundle.main.url(forResource: "catalog-bundle", withExtension: "json"), appVersion: appVersion)
        installer = Installer(paths: paths)
        github = GitHubProfileService(paths: paths)
        library = store.state
        reloadCatalog()
    }

    func reloadCatalog() {
        do {
            let loaded = try catalogStore.load()
            index = loaded.index
            search = SearchEngine(index: loaded.index)
            catalogSource = loaded.source
            quarantined = loaded.quarantined
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    // MARK: Library

    private func sync() { library = store.state }

    func isFavorite(_ id: String) -> Bool { library.favorites.contains(id) }
    func toggleFavorite(_ id: String) { store.toggleFavorite(id); sync() }
    func recordView(_ id: String) { store.recordView(id); sync() }
    func clearRecents() { store.clearRecents(); sync() }

    @discardableResult func createCollection(_ name: String, with ids: [String] = []) -> UserCollection {
        let c = store.createCollection(named: name, resourceIDs: ids); sync(); return c
    }
    func addToCollection(_ c: UUID, _ id: String) { store.addToCollection(c, resourceID: id); sync(); show("Added to collection") }
    func removeFromCollection(_ c: UUID, _ id: String) { store.removeFromCollection(c, resourceID: id); sync() }
    func renameCollection(_ c: UUID, _ name: String) { store.renameCollection(c, to: name); sync() }
    func deleteCollection(_ c: UUID) { store.deleteCollection(c); sync() }

    var installedIDs: Set<String> { Set(library.installs.map(\.resourceID)) }
    func installs(for id: String) -> [InstallRecord] { library.installs.filter { $0.resourceID == id } }

    func updateAvailable(_ record: InstallRecord) -> Resource? {
        guard let r = index?.resource(record.resourceID) else { return nil }
        if SemVer.isNewer(r.version, than: record.version) || (r.version == record.version && r.contentSha256 != record.contentSha256) { return r }
        return nil
    }

    var installsWithUpdates: [(InstallRecord, Resource)] {
        library.installs.compactMap { rec in updateAvailable(rec).map { (rec, $0) } }
    }

    func resources(_ ids: [String]) -> [Resource] { ids.compactMap { index?.resource($0) } }

    // MARK: Navigation

    func open(_ route: Route) {
        if path.last != route { path.append(route) }
    }

    func openResource(_ id: String) { open(.resource(id)) }

    /// skilldeck://resource/<id>, skilldeck://contributor/<login>, skilldeck://collection/<id>, skilldeck://search?q=<text>,
    /// skilldeck://section/<discover|all|agents|skills|prompts|routines|collections|contributors|installed|updates|favorites|settings>
    func handleDeepLink(_ url: URL) {
        guard url.scheme == "skilldeck", let host = url.host else { return }
        let arg = url.pathComponents.dropFirst().first ?? ""
        switch host {
        case "resource" where index?.resource(arg) != nil: path = [.resource(arg)]
        case "contributor" where index?.contributor(arg) != nil: path = [.contributor(arg.lowercased())]
        case "collection" where index?.collectionsByID[arg] != nil: path = [.collection(arg)]
        case "search":
            select(.all)
            searchText = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == "q" }?.value ?? ""
        case "section":
            let map: [String: SidebarItem] = ["discover": .discover, "all": .all, "agents": .type(.agent), "skills": .type(.skill),
                                              "prompts": .type(.prompt), "routines": .type(.routine), "collections": .collections,
                                              "contributors": .contributors, "installed": .installed, "updates": .updates,
                                              "favorites": .favorites, "settings": .settings]
            if let item = map[arg] { select(item) }
        default: break
        }
    }

    func select(_ item: SidebarItem) {
        selection = item
        path = []
    }

    func show(_ message: String, error: Bool = false) {
        toast = Toast(message: message, isError: error)
        let id = toast?.id
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            if toast?.id == id { toast = nil }
        }
    }

    // MARK: Copy

    func copyToPasteboard(_ text: String, label: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        show("Copied \(label)")
    }

    /// The complete, ready-to-use content for a resource.
    func primaryContent(_ r: Resource) -> String {
        switch r.type {
        case .prompt: Markdown.promptText(r.entrypointContent) ?? r.entrypointContent
        default: r.entrypointContent
        }
    }

    // MARK: Installation

    func plan(_ r: Resource, platformID: String, scope: InstallScope, projectRoot: URL?, customRoot: URL?) throws -> InstallPlan {
        guard let index, let platform = index.platformsByID[platformID] else { throw InstallError.unsupported(platform: platformID, type: r.type) }
        return try installer.plan(resource: r, platform: platform, scope: scope, projectRoot: projectRoot, customRoot: customRoot, existing: library.installs)
    }

    func execute(_ plan: InstallPlan, resolution: ConflictResolution) throws -> InstallResult {
        let result = try installer.execute(plan, resolution: resolution)
        store.upsertInstall(result.record)
        sync()
        return result
    }

    func uninstall(_ record: InstallRecord, force: Bool = false) {
        do {
            let kept = try installer.uninstall(record, force: force)
            store.removeInstall(record.id)
            sync()
            show(kept.isEmpty ? "Uninstalled \(record.resourceName)" : "Uninstalled; kept \(kept.count) file(s) you modified")
        } catch {
            show(error.localizedDescription, error: true)
        }
    }

    func modifiedFiles(_ record: InstallRecord) -> [String] { installer.modifiedFiles(record) }

    /// Updates an installed resource in place. Modified files are only replaced when `allowOverwriteModified` (they are backed up first).
    func updateInstalled(_ record: InstallRecord, allowOverwriteModified: Bool) throws {
        guard let r = index?.resource(record.resourceID), let platform = index?.platformsByID[record.platform] else { return }
        let location = URL(fileURLWithPath: record.location)
        var projectRoot: URL?, customRoot: URL?
        switch record.scope {
        case .user: break
        case .project:
            let target = platform.target(for: r.type)
            let depth = (target?.projectPath ?? "").split(separator: "/").count
            projectRoot = (0..<depth).reduce(location) { u, _ in u.deletingLastPathComponent() }
        case .custom: customRoot = location.deletingLastPathComponent()
        }
        let p = try installer.plan(resource: r, platform: platform, scope: record.scope, projectRoot: projectRoot, customRoot: customRoot, existing: library.installs)
        let result = try installer.execute(p, resolution: allowOverwriteModified ? .backupAndReplace : .abort)
        // Drop any stale record for the same location, then store the new one.
        store.removeInstall(record.id)
        store.upsertInstall(result.record)
        store.addHistory(UpdateHistoryEntry(id: UUID(), date: Date(), kind: "resource", fromVersion: record.version, toVersion: r.version, summary: "Updated \(r.name)"))
        sync()
    }

    // MARK: Export

    func export(resources: [Resource], suggestedName: String) {
        guard !resources.isEmpty else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = suggestedName + ".zip"
        panel.allowedContentTypes = [.zip]
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let index = resources.map { "- \($0.name) (\($0.type.displayName), v\($0.version)) — \($0.id)/" }.joined(separator: "\n")
            let header = "# \(suggestedName)\n\nExported from Skilldeck catalog \(self.index?.catalog.catalogVersion ?? "").\n\n" + index + "\n"
            let data = try Installer.exportArchive(resources: resources, includeIndex: header)
            try data.write(to: url, options: .atomic)
            show("Exported \(resources.count) resource\(resources.count == 1 ? "" : "s")")
        } catch {
            show(error.localizedDescription, error: true)
        }
    }

    func exportCatalog() {
        guard let index else { return }
        export(resources: index.resources, suggestedName: "skilldeck-catalog-\(index.catalog.catalogVersion)")
    }

    func exportAgentsMarkdown(_ r: Resource) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "AGENTS-\(r.id).md"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try Data(Installer.agentsMarkdownSection(for: r).utf8).write(to: url, options: .atomic)
            show("Saved AGENTS.md section")
        } catch { show(error.localizedDescription, error: true) }
    }

    func reveal(_ path: String) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
    }

    func openURL(_ string: String?) {
        guard let url = URLSafety.safeWebURL(string) else { return }
        NSWorkspace.shared.open(url)
    }

    // MARK: Updates

    /// Checks at launch and then every `updateCheckIntervalHours` while the app runs.
    func runUpdateLoop() async {
        while !Task.isCancelled {
            await backgroundUpdateIfDue(force: true)
            let hours = max(1, updateCheckIntervalHours)
            try? await Task.sleep(for: .seconds(Double(hours) * 3600))
        }
    }

    /// Background check; also used when the app becomes active after sleeping.
    func backgroundUpdateIfDue(force: Bool = false) async {
        guard autoCheckUpdates else { return }
        if !force, let last = lastUpdateCheck, Date().timeIntervalSince(last) < Double(max(1, updateCheckIntervalHours)) * 3600 { return }
        await checkForUpdates(userInitiated: false)
        if autoInstallCatalogUpdates, updateCheck?.isNewer == true {
            await applyCatalogUpdate()
        }
    }

    var newResources: [Resource] { newResourceIDs.compactMap { index?.resource($0) } }
    func dismissNewResources() { newResourceIDs = [] }

    func checkForUpdates(userInitiated: Bool) async {
        guard let index, !isCheckingUpdates else { return }
        isCheckingUpdates = true
        updateError = nil
        defer { isCheckingUpdates = false; lastUpdateCheck = Date() }
        do {
            let service = UpdateService(store: catalogStore)
            updateCheck = try await service.check(endpoint: catalogEndpoint, current: index)
            if userInitiated && updateCheck?.isNewer == false { show("Catalog is up to date") }
        } catch {
            updateCheck = nil
            if userInitiated { updateError = error.localizedDescription }
        }
    }

    func applyCatalogUpdate() async {
        guard let check = updateCheck, let index, !isApplyingUpdate else { return }
        isApplyingUpdate = true
        defer { isApplyingUpdate = false }
        do {
            let service = UpdateService(store: catalogStore)
            let old = index.catalog
            let new = try await service.apply(check, current: index)
            let changes = UpdateService.diff(old: old, new: new)
            store.addHistory(UpdateHistoryEntry(id: UUID(), date: Date(), kind: "catalog", fromVersion: old.catalogVersion, toVersion: new.catalogVersion,
                                                summary: "\(changes.added.count) added, \(changes.updated.count) updated, \(changes.removed.count) removed"))
            sync()
            reloadCatalog()
            updateCheck = nil
            let added = changes.added.filter { self.index?.resource($0) != nil }
            newResourceIDs = added + newResourceIDs.filter { !added.contains($0) && self.index?.resource($0) != nil }
            show(added.isEmpty ? "Catalog updated to \(new.catalogVersion)"
                 : "Catalog \(new.catalogVersion): \(added.count) new resource\(added.count == 1 ? "" : "s") — see Discover")
        } catch {
            updateError = error.localizedDescription
            show("Update failed; your current catalog was kept.", error: true)
        }
    }

    func rollbackCatalog() {
        do {
            let from = index?.catalog.catalogVersion
            try catalogStore.rollback()
            reloadCatalog()
            store.addHistory(UpdateHistoryEntry(id: UUID(), date: Date(), kind: "rollback", fromVersion: from, toVersion: index?.catalog.catalogVersion ?? "", summary: "Rolled back catalog"))
            sync()
            show("Restored catalog \(index?.catalog.catalogVersion ?? "")")
        } catch { show(error.localizedDescription, error: true) }
    }

    func resetCatalogToBundled() {
        do { try catalogStore.resetToBundled(); reloadCatalog(); show("Using the bundled catalog") } catch { show(error.localizedDescription, error: true) }
    }

    // MARK: Contributors

    func loadProfile(_ login: String) async {
        guard fetchGitHubProfiles else {
            if let cached = await github.cachedProfile(login) { profiles[login.lowercased()] = cached }
            return
        }
        if let p = await github.profile(login) { profiles[login.lowercased()] = p }
    }

    func resetLocalData() {
        store.resetAll()
        sync()
        Task { await github.clearCache() }
        show("Local data cleared")
    }
}
