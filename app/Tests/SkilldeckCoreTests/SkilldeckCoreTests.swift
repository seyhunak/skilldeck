import Foundation
import XCTest
@testable import SkilldeckCore

// MARK: - Helpers

func fixtureData(_ name: String) throws -> Data {
    let url = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures"))
    return try Data(contentsOf: url)
}

func tempDir() -> URL {
    let u = FileManager.default.temporaryDirectory.appendingPathComponent("skilldeck-tests-\(UUID().uuidString)", isDirectory: true)
    try? FileManager.default.createDirectory(at: u, withIntermediateDirectories: true)
    return u
}

final class MockHTTP: HTTPClient, @unchecked Sendable {
    var responses: [String: (Data, Int, [String: String])] = [:]
    var requests: [URL] = []
    var failAll = false
    func get(_ url: URL) async throws -> (Data, HTTPURLResponse) {
        requests.append(url)
        if failAll { throw URLError(.notConnectedToInternet) }
        guard let (data, code, headers) = responses[url.absoluteString] else {
            return (Data(), HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!)
        }
        return (data, HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: headers)!)
    }
}

func loadFixtureIndex(_ name: String = "catalog-1.0.0") throws -> CatalogIndex {
    let (catalog, bad) = try CatalogStore.verify(try fixtureData(name), appVersion: "1.0.0")
    XCTAssertEqual(bad, [])
    return CatalogIndex(catalog)
}

// MARK: - Catalog loading & integrity

final class CatalogTests: XCTestCase {
    func testDecodesFixtureCatalog() throws {
        let index = try loadFixtureIndex()
        XCTAssertEqual(index.catalog.catalogVersion, "1.0.0")
        XCTAssertEqual(index.resources.count, 6)
        let agent = try XCTUnwrap(index.resource("repository-intelligence-agent"))
        XCTAssertEqual(agent.type, .agent)
        XCTAssertTrue(agent.entrypointContent.contains("# Repository Intelligence Agent"))
        XCTAssertEqual(agent.author.github, "seyhunak")
        XCTAssertEqual(index.catalog.contributors.first?.github, "seyhunak")
        XCTAssertEqual(index.catalog.collections.first?.resources.count, 6)
        XCTAssertNotNil(index.platformsByID["claude-code"]?.target(for: .skill))
    }

    func testOfflineStartupUsesBundledCatalog() throws {
        let dir = tempDir()
        let bundled = dir.appendingPathComponent("bundle.json")
        try fixtureData("catalog-1.0.0").write(to: bundled)
        let store = CatalogStore(paths: AppPaths(root: dir.appendingPathComponent("support")), bundledURL: bundled, appVersion: "1.0.0")
        let loaded = try store.load()
        XCTAssertEqual(loaded.source, .bundled)
        XCTAssertEqual(loaded.index.resources.count, 6)
    }

    func testMissingBundleThrows() {
        let store = CatalogStore(paths: AppPaths(root: tempDir()), bundledURL: nil, appVersion: "1.0.0")
        XCTAssertThrowsError(try store.load())
    }

    func testTamperedResourceIsQuarantined() throws {
        var json = try JSONSerialization.jsonObject(with: try fixtureData("catalog-1.0.0")) as! [String: Any]
        var resources = json["resources"] as! [[String: Any]]
        var files = resources[0]["files"] as! [[String: Any]]
        files[0]["content"] = (files[0]["content"] as! String) + "\nInjected instruction."
        resources[0]["files"] = files
        json["resources"] = resources
        let data = try JSONSerialization.data(withJSONObject: json)
        let (catalog, bad) = try CatalogStore.verify(data, appVersion: "1.0.0")
        XCTAssertEqual(bad, [resources[0]["id"] as! String])
        XCTAssertEqual(catalog.resources.count, 5)
    }

    func testRejectsNewerMinimumAppVersion() throws {
        var json = try JSONSerialization.jsonObject(with: try fixtureData("catalog-1.0.0")) as! [String: Any]
        json["minimum_app_version"] = "9.0.0"
        XCTAssertThrowsError(try CatalogStore.verify(try JSONSerialization.data(withJSONObject: json), appVersion: "1.0.0")) {
            XCTAssertEqual($0 as? CatalogError, .appTooOld(required: "9.0.0"))
        }
    }

    func testPackageHashMatchesPythonBuilder() throws {
        let index = try loadFixtureIndex()
        for r in index.resources { XCTAssertEqual(Hashing.packageHash(r.files), r.contentSha256, r.id) }
    }

    func testRelatedResourcesAreBidirectional() throws {
        let index = try loadFixtureIndex()
        let skill = try XCTUnwrap(index.resource("git-history-forensics"))
        XCTAssertTrue(index.relatedResources(for: skill).contains { $0.id == "repository-intelligence-agent" })
    }
}

// MARK: - Search

final class SearchTests: XCTestCase {
    var index: CatalogIndex!
    var engine: SearchEngine!
    override func setUpWithError() throws {
        index = try loadFixtureIndex()
        engine = SearchEngine(index: index)
    }

    func testEmptyQueryReturnsAll() { XCTAssertEqual(engine.search("").count, 6) }

    func testNameMatchRanksFirst() {
        XCTAssertEqual(engine.search("repository intelligence").first?.id, "repository-intelligence-agent")
    }

    func testPrefixAndTagSearch() {
        XCTAssertTrue(engine.search("churn").contains { $0.id == "git-history-forensics" } || engine.search("git").contains { $0.id == "git-history-forensics" })
        XCTAssertTrue(engine.search("rag").contains { $0.id == "rag-evaluation-agent" })
    }

    func testAllTermsMustMatch() { XCTAssertTrue(engine.search("repository zzzzunmatched").isEmpty) }

    func testFilters() {
        var f = SearchFilters()
        f.types = [.skill]
        XCTAssertTrue(engine.search("", filters: f).allSatisfy { $0.type == .skill })
        f = SearchFilters(); f.domains = ["ai-machine-learning"]
        XCTAssertEqual(engine.search("", filters: f).map(\.id), ["rag-evaluation-agent"])
        f = SearchFilters(); f.installState = .installed
        XCTAssertEqual(engine.search("", filters: f, installedIDs: ["git-history-forensics"]).map(\.id), ["git-history-forensics"])
        f = SearchFilters(); f.platforms = ["claude-desktop"]; f.minimumLevel = .nativeImport
        XCTAssertTrue(engine.search("", filters: f).allSatisfy { $0.type == .skill })
        f = SearchFilters(); f.featuredOnly = true
        XCTAssertTrue(engine.search("", filters: f).allSatisfy(\.featured))
        f = SearchFilters(); f.authors = ["seyhunak"]; f.useCases = ["rag-development"]
        XCTAssertEqual(engine.search("", filters: f).count, 1)
    }

    func testSortingAndSuggestions() {
        let byName = engine.search("", sort: .name).map(\.name)
        XCTAssertEqual(byName, byName.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })
        XCTAssertFalse(engine.suggestions(for: "repo").isEmpty)
        XCTAssertTrue(engine.suggestions(for: "r").isEmpty)
    }
}

// MARK: - Markdown

final class MarkdownTests: XCTestCase {
    func testFrontmatterSectionsAndPrompt() throws {
        let index = try loadFixtureIndex()
        let agent = try XCTUnwrap(index.resource("repository-intelligence-agent"))
        let (fm, body) = Markdown.splitFrontmatter(agent.entrypointContent)
        XCTAssertEqual(fm["name"], "repository-intelligence-agent")
        XCTAssertTrue(body.hasPrefix("# "))
        XCTAssertNotNil(Markdown.section(agent.entrypointContent, startingWith: "Operating procedure"))
        XCTAssertTrue(Markdown.preamble(agent.entrypointContent).hasPrefix("You are"))

        let prompt = try XCTUnwrap(index.resource("explain-unfamiliar-code-prompt"))
        let text = try XCTUnwrap(Markdown.promptText(prompt.entrypointContent))
        XCTAssertFalse(Markdown.placeholders(text).isEmpty)
    }

    func testBlocksParseListsTablesAndCodeWithoutHTML() {
        let md = "# T\n\nPara <script>x</script>\n\n- a\n- [ ] b\n\n1. one\n2. two\n\n| A | B |\n|---|---|\n| 1 | 2 |\n\n```text\n## not a heading\n```\n"
        let blocks = Markdown.blocks(md)
        XCTAssertEqual(blocks.first, .heading(level: 1, text: "T"))
        XCTAssertTrue(blocks.contains(.paragraph("Para <script>x</script>")))  // kept as literal text
        XCTAssertTrue(blocks.contains(.table(header: ["A", "B"], rows: [["1", "2"]])))
        XCTAssertTrue(blocks.contains(.code(language: "text", text: "## not a heading")))
        XCTAssertTrue(Markdown.sections(md).isEmpty)
    }

    func testNestedFencesStayInOneCodeBlock() {
        let md = "## Out\n\n````markdown\n# Doc\n```mermaid\nflowchart LR\n```\n## not a section\n````\n\nAfter\n"
        let blocks = Markdown.blocks(md)
        XCTAssertTrue(blocks.contains(.code(language: "markdown", text: "# Doc\n```mermaid\nflowchart LR\n```\n## not a section")))
        XCTAssertTrue(blocks.contains(.paragraph("After")))
        XCTAssertEqual(Markdown.sections(md).map(\.title), ["Out"])
        XCTAssertEqual(Markdown.firstCodeBlock("````\na\n```\nb\n```\n````"), "a\n```\nb\n```")
    }
}

// MARK: - Utilities

final class UtilityTests: XCTestCase {
    func testSemVer() {
        XCTAssertTrue(SemVer.isNewer("1.10.0", than: "1.9.9"))
        XCTAssertFalse(SemVer.isNewer("1.0.0", than: "1.0.0"))
        XCTAssertFalse(SemVer.isNewer("garbage", than: "1.0.0"))
        XCTAssertEqual(SemVer("v2.3.4")?.description, "2.3.4")
    }

    func testPathSafety() throws {
        for bad in ["../x", "/etc/passwd", "a/../../b", "~/x", "a\\b", "", "a//b", "./a"] {
            XCTAssertThrowsError(try PathSafety.validateRelative(bad), bad)
        }
        let root = tempDir()
        XCTAssertNoThrow(try PathSafety.resolve("references/a.md", under: root))
        XCTAssertThrowsError(try PathSafety.resolve("../escape.md", under: root))
    }

    func testSymlinkRefused() throws {
        let root = tempDir()
        let outside = tempDir()
        try FileManager.default.createSymbolicLink(at: root.appendingPathComponent("link"), withDestinationURL: outside)
        XCTAssertThrowsError(try PathSafety.assertNoSymlinks(from: root, to: root.appendingPathComponent("link/file.md")))
    }

    func testURLSafety() {
        XCTAssertNotNil(URLSafety.safeWebURL("https://github.com/x"))
        XCTAssertNil(URLSafety.safeWebURL("javascript:alert(1)"))
        XCTAssertNil(URLSafety.safeWebURL("file:///etc/passwd"))
        XCTAssertNil(URLSafety.safeWebURL("http://example.com"))
        XCTAssertTrue(URLSafety.isValidGitHubLogin("octo-cat"))
        XCTAssertFalse(URLSafety.isValidGitHubLogin("../etc"))
    }

    func testZipWriterProducesValidArchive() throws {
        var zip = ZipWriter()
        try zip.add(path: "a/one.md", contents: Data("hello".utf8))
        try zip.add(path: "a/two.md", contents: Data("world".utf8))
        XCTAssertThrowsError(try zip.add(path: "../evil", contents: Data()))
        let url = tempDir().appendingPathComponent("t.zip")
        try zip.finalize().write(to: url)
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        p.arguments = ["-tq", url.path]
        let pipe = Pipe(); p.standardOutput = pipe; p.standardError = pipe
        try p.run(); p.waitUntilExit()
        XCTAssertEqual(p.terminationStatus, 0, String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "")
    }
}

// MARK: - Persistence

final class LibraryStoreTests: XCTestCase {
    func testFavoritesRecentsCollectionsPersist() {
        let url = tempDir().appendingPathComponent("library.json")
        let store = LibraryStore(url: url)
        store.toggleFavorite("a")
        store.recordView("x"); store.recordView("y"); store.recordView("x")
        let c = store.createCollection(named: " Mine ")
        store.addToCollection(c.id, resourceID: "a")
        store.addToCollection(c.id, resourceID: "a")
        let reloaded = LibraryStore(url: url)
        XCTAssertEqual(reloaded.state.favorites, ["a"])
        XCTAssertEqual(reloaded.state.recents.map(\.resourceID), ["x", "y"])
        XCTAssertEqual(reloaded.state.collections.first?.name, "Mine")
        XCTAssertEqual(reloaded.state.collections.first?.resourceIDs, ["a"])
        reloaded.toggleFavorite("a")
        XCTAssertFalse(reloaded.isFavorite("a"))
    }

    func testCorruptFileIsMovedAside() throws {
        let dir = tempDir()
        let url = dir.appendingPathComponent("library.json")
        try Data("{not json".utf8).write(to: url)
        let store = LibraryStore(url: url)
        XCTAssertTrue(store.state.favorites.isEmpty)
        XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: dir.path).contains { $0.contains("corrupt") })
    }

    func testRecentsAreCapped() {
        let store = LibraryStore(url: tempDir().appendingPathComponent("l.json"))
        for i in 0..<80 { store.recordView("r\(i)") }
        XCTAssertEqual(store.state.recents.count, LibraryStore.maxRecents)
    }
}

// MARK: - Installation

final class InstallerTests: XCTestCase {
    var index: CatalogIndex!
    var home: URL!
    var installer: Installer!

    override func setUpWithError() throws {
        index = try loadFixtureIndex()
        home = tempDir()
        installer = Installer(paths: AppPaths(root: home.appendingPathComponent("support")), home: home)
    }

    func platform(_ id: String) -> Platform { index.platformsByID[id]! }

    func testInstallSkillIntoClaudeCodeCopiesPackage() throws {
        let skill = index.resource("git-history-forensics")!
        let plan = try installer.plan(resource: skill, platform: platform("claude-code"), scope: .user)
        XCTAssertEqual(plan.primaryLocation.path, home.appendingPathComponent(".claude/skills/git-history-forensics").path)
        XCTAssertTrue(plan.conflicts.isEmpty)
        let result = try installer.execute(plan)
        let skillMD = home.appendingPathComponent(".claude/skills/git-history-forensics/SKILL.md")
        XCTAssertEqual(try String(contentsOf: skillMD, encoding: .utf8), skill.file("SKILL.md")?.content)
        XCTAssertEqual(result.record.files.count, skill.files.count)
        XCTAssertTrue(installer.modifiedFiles(result.record).isEmpty)
    }

    func testInstallAgentWritesSubagentFileAndSupportFiles() throws {
        let agent = index.resource("repository-intelligence-agent")!
        let plan = try installer.plan(resource: agent, platform: platform("claude-code"), scope: .user)
        let result = try installer.execute(plan)
        let agentFile = home.appendingPathComponent(".claude/agents/repository-intelligence-agent.md")
        let text = try String(contentsOf: agentFile, encoding: .utf8)
        XCTAssertTrue(text.hasPrefix("---\nname: repository-intelligence-agent"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: home.appendingPathComponent(".claude/skilldeck/packages/repository-intelligence-agent/references/survey-checklist.md").path))
        XCTAssertEqual(result.record.location, agentFile.path)
    }

    func testPromptInstallsAsCommandWithArguments() throws {
        let prompt = index.resource("explain-unfamiliar-code-prompt")!
        let plan = try installer.plan(resource: prompt, platform: platform("codex"), scope: .user)
        _ = try installer.execute(plan)
        let text = try String(contentsOf: home.appendingPathComponent(".codex/prompts/explain-unfamiliar-code-prompt.md"), encoding: .utf8)
        XCTAssertTrue(text.hasPrefix("---\ndescription:"))
        XCTAssertTrue(text.contains("$ARGUMENTS"))
        XCTAssertTrue(text.contains(Markdown.promptText(prompt.entrypointContent)!.trimmingCharacters(in: .whitespacesAndNewlines)))
    }

    func testExportOnlyTargetsAreRejectedForInstall() {
        let agent = index.resource("repository-intelligence-agent")!
        XCTAssertThrowsError(try installer.plan(resource: agent, platform: platform("codex"), scope: .user)) {
            guard case InstallError.requiresExport = $0 else { return XCTFail("\($0)") }
        }
    }

    func testProjectAndCustomScopes() throws {
        let skill = index.resource("git-history-forensics")!
        let project = tempDir()
        let plan = try installer.plan(resource: skill, platform: platform("claude-code"), scope: .project, projectRoot: project)
        XCTAssertTrue(plan.primaryLocation.path.hasPrefix(project.appendingPathComponent(".claude/skills").path))
        XCTAssertThrowsError(try installer.plan(resource: skill, platform: platform("claude-code"), scope: .project, projectRoot: nil))
        let custom = tempDir()
        let p2 = try installer.plan(resource: skill, platform: platform("generic"), scope: .custom, customRoot: custom)
        _ = try installer.execute(p2)
        XCTAssertTrue(FileManager.default.fileExists(atPath: custom.appendingPathComponent("git-history-forensics/SKILL.md").path))
    }

    func testNeverSilentlyOverwritesUserFiles() throws {
        let skill = index.resource("git-history-forensics")!
        let dest = home.appendingPathComponent(".claude/skills/git-history-forensics/SKILL.md")
        try FileManager.default.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("my own skill".utf8).write(to: dest)
        let plan = try installer.plan(resource: skill, platform: platform("claude-code"), scope: .user)
        XCTAssertEqual(plan.conflicts.count, 1)
        XCTAssertThrowsError(try installer.execute(plan))
        XCTAssertEqual(try String(contentsOf: dest, encoding: .utf8), "my own skill")
        let result = try installer.execute(plan, resolution: .backupAndReplace)
        let backup = try XCTUnwrap(result.backupLocation)
        let backedUp = try FileManager.default.contentsOfDirectory(atPath: backup.path).filter { $0.hasSuffix("SKILL.md") }
        XCTAssertEqual(try String(contentsOf: backup.appendingPathComponent(backedUp[0]), encoding: .utf8), "my own skill")
    }

    func testReinstallOfUnmodifiedInstallIsNotAConflict() throws {
        let skill = index.resource("git-history-forensics")!
        let first = try installer.execute(try installer.plan(resource: skill, platform: platform("claude-code"), scope: .user))
        let again = try installer.plan(resource: skill, platform: platform("claude-code"), scope: .user, existing: [first.record])
        XCTAssertTrue(again.conflicts.isEmpty)
        XCTAssertTrue(again.isReinstall)
        // After a local edit it becomes a conflict.
        try Data("edited".utf8).write(to: URL(fileURLWithPath: first.record.files[0].path))
        let edited = try installer.plan(resource: skill, platform: platform("claude-code"), scope: .user, existing: [first.record])
        XCTAssertEqual(edited.conflicts.count, 1)
    }

    func testUninstallKeepsModifiedFilesUnlessForced() throws {
        let skill = index.resource("git-history-forensics")!
        let rec = try installer.execute(try installer.plan(resource: skill, platform: platform("claude-code"), scope: .user)).record
        let modifiedPath = rec.files[0].path
        try Data("changed".utf8).write(to: URL(fileURLWithPath: modifiedPath))
        XCTAssertEqual(installer.modifiedFiles(rec), [modifiedPath])
        let kept = try installer.uninstall(rec)
        XCTAssertEqual(kept, [modifiedPath])
        XCTAssertTrue(FileManager.default.fileExists(atPath: modifiedPath))
        try installer.uninstall(rec, force: true)
        XCTAssertFalse(FileManager.default.fileExists(atPath: modifiedPath))
    }

    func testScriptPackagesAreRefused() {
        var skill = index.resource("git-history-forensics")!
        skill.safety.containsScripts = true
        XCTAssertThrowsError(try installer.plan(resource: skill, platform: platform("claude-code"), scope: .user))
    }

    func testUnsafePathInCatalogIsRefused() {
        var skill = index.resource("git-history-forensics")!
        skill.files.append(ResourceFile(path: "../../.zshrc", size: 1, sha256: "x", content: "evil"))
        XCTAssertThrowsError(try installer.plan(resource: skill, platform: platform("claude-code"), scope: .user))
    }

    func testInstallTargetsRespectRegistry() {
        let agent = index.resource("repository-intelligence-agent")!
        let ids = Installer.installTargets(for: agent, in: index).map(\.0.id)
        XCTAssertTrue(ids.contains("claude-code"))
        XCTAssertFalse(ids.contains("codex"))
        XCTAssertFalse(ids.contains("claude-desktop"))
    }

    func testExportArchiveAndFolder() throws {
        let resources = Array(index.resources.prefix(3))
        let data = try Installer.exportArchive(resources: resources, includeIndex: "# Index\n")
        XCTAssertGreaterThan(data.count, 1000)
        let dir = tempDir()
        let out = try Installer.exportFolder(resource: resources[0], to: dir)
        XCTAssertTrue(FileManager.default.fileExists(atPath: out.appendingPathComponent("manifest.yaml").path))
        XCTAssertThrowsError(try Installer.exportFolder(resource: resources[0], to: dir))
    }

    func testCopyContentAndInstructions() throws {
        let agent = index.resource("repository-intelligence-agent")!
        XCTAssertTrue(Installer.agentsMarkdownSection(for: agent).contains("skilldeck:repository-intelligence-agent@"))
        let text = Installer.instructions(for: agent, in: index)
        XCTAssertTrue(text.contains("~/.claude/agents/repository-intelligence-agent.md"))
    }
}

// MARK: - Updates

final class UpdateTests: XCTestCase {
    let endpoint = "https://example.com/latest.json"
    let bundleURL = "https://example.com/catalog-bundle.json"

    func pointer(for data: Data, version: String, sha: String? = nil) -> Data {
        let p: [String: Any] = [
            "schema_version": "1.1", "catalog_id": "skilldeck-community", "catalog_version": version,
            "generated_at": "2026-11-09T00:00:00Z", "minimum_app_version": "1.0.0", "resources_count": 6,
            "bundle": ["url": bundleURL, "sha256": sha ?? Hashing.sha256(data), "size": data.count],
            "changes": ["previous_version": "1.0.0", "added": [], "updated": ["git-history-forensics"], "removed": []],
        ]
        return try! JSONSerialization.data(withJSONObject: p)
    }

    func makeStore() throws -> (CatalogStore, CatalogIndex) {
        let dir = tempDir()
        let bundled = dir.appendingPathComponent("bundle.json")
        try fixtureData("catalog-1.0.0").write(to: bundled)
        let store = CatalogStore(paths: AppPaths(root: dir.appendingPathComponent("support")), bundledURL: bundled, appVersion: "1.0.0")
        return (store, try store.load().index)
    }

    func testCheckApplyAndRollback() async throws {
        let (store, current) = try makeStore()
        let newData = try fixtureData("catalog-1.1.0")
        let http = MockHTTP()
        http.responses[endpoint] = (pointer(for: newData, version: "1.1.0"), 200, [:])
        http.responses[bundleURL] = (newData, 200, [:])
        let service = UpdateService(client: http, store: store)
        let check = try await service.check(endpoint: endpoint, current: current)
        XCTAssertTrue(check.isNewer)
        XCTAssertEqual(check.updated, ["git-history-forensics"])
        let new = try await service.apply(check, current: current)
        XCTAssertEqual(new.catalogVersion, "1.1.0")
        let reloaded = try store.load()
        XCTAssertEqual(reloaded.source, .downloaded)
        XCTAssertEqual(reloaded.index.catalog.catalogVersion, "1.1.0")
        XCTAssertEqual(UpdateService.diff(old: current.catalog, new: new).added, [])
        // Rollback with no previous downloaded catalog falls back to the bundle.
        try store.rollback()
        XCTAssertEqual(try store.load().index.catalog.catalogVersion, "1.0.0")
    }

    func testHashMismatchKeepsCurrentCatalog() async throws {
        let (store, current) = try makeStore()
        let newData = try fixtureData("catalog-1.1.0")
        let http = MockHTTP()
        http.responses[endpoint] = (pointer(for: newData, version: "1.1.0", sha: String(repeating: "0", count: 64)), 200, [:])
        http.responses[bundleURL] = (newData, 200, [:])
        let service = UpdateService(client: http, store: store)
        let check = try await service.check(endpoint: endpoint, current: current)
        do {
            _ = try await service.apply(check, current: current)
            XCTFail("expected hash mismatch")
        } catch let e as CatalogError {
            guard case .hashMismatch = e else { return XCTFail("\(e)") }
        }
        XCTAssertEqual(try store.load().source, .bundled)
    }

    func testCorruptDownloadIsRejected() async throws {
        let (store, current) = try makeStore()
        let garbage = Data("{\"not\": \"a catalog\"}".utf8)
        let http = MockHTTP()
        http.responses[endpoint] = (pointer(for: garbage, version: "1.1.0"), 200, [:])
        http.responses[bundleURL] = (garbage, 200, [:])
        let service = UpdateService(client: http, store: store)
        let check = try await service.check(endpoint: endpoint, current: current)
        do { _ = try await service.apply(check, current: current); XCTFail("expected failure") } catch {}
        XCTAssertEqual(try store.load().index.catalog.catalogVersion, "1.0.0")
    }

    func testSameVersionIsNotAnUpdateAndOfflineFails() async throws {
        let (store, current) = try makeStore()
        let data = try fixtureData("catalog-1.0.0")
        let http = MockHTTP()
        http.responses[endpoint] = (pointer(for: data, version: "1.0.0"), 200, [:])
        let check = try await UpdateService(client: http, store: store).check(endpoint: endpoint, current: current)
        XCTAssertFalse(check.isNewer)
        http.failAll = true
        do { _ = try await UpdateService(client: http, store: store).check(endpoint: endpoint, current: current); XCTFail() } catch {}
        do { _ = try await UpdateService(client: http, store: store).check(endpoint: "http://insecure", current: current); XCTFail() } catch {}
    }

    func testRollbackRestoresPreviousDownloadedCatalog() throws {
        let (store, _) = try makeStore()
        let v11 = try fixtureData("catalog-1.1.0")
        try store.install(bundleData: v11, expectedSHA256: Hashing.sha256(v11), currentVersion: "1.0.0")
        // Simulate a second update by re-tagging the 1.1.0 bundle as 1.2.0.
        var json = try JSONSerialization.jsonObject(with: v11) as! [String: Any]
        json["catalog_version"] = "1.2.0"
        let v12 = try JSONSerialization.data(withJSONObject: json)
        try store.install(bundleData: v12, expectedSHA256: Hashing.sha256(v12), currentVersion: "1.1.0")
        XCTAssertEqual(try store.load().index.catalog.catalogVersion, "1.2.0")
        XCTAssertTrue(store.canRollback)
        try store.rollback()
        XCTAssertEqual(try store.load().index.catalog.catalogVersion, "1.1.0")
        XCTAssertThrowsError(try store.install(bundleData: v11, expectedSHA256: Hashing.sha256(v11), currentVersion: "1.1.0"))
    }
}

// MARK: - GitHub profiles

final class GitHubProfileTests: XCTestCase {
    func testCachesAndFallsBackOffline() async throws {
        let http = MockHTTP()
        let body = try JSONSerialization.data(withJSONObject: ["login": "octocat", "name": "The Octocat", "bio": "Hi", "blog": "octo.dev"])
        http.responses["https://api.github.com/users/octocat"] = (body, 200, [:])
        let paths = AppPaths(root: tempDir())
        let service = GitHubProfileService(client: http, paths: paths)
        let p = await service.profile("octocat")
        XCTAssertEqual(p?.name, "The Octocat")
        XCTAssertEqual(p?.blog, "https://octo.dev")
        // Second call within TTL uses the cache.
        _ = await service.profile("OctoCat")
        XCTAssertEqual(http.requests.count, 1)
        // A fresh service offline still returns the disk cache.
        http.failAll = true
        let offline = GitHubProfileService(client: http, paths: paths)
        let cached = await offline.profile("octocat", now: Date().addingTimeInterval(3 * 86400))
        XCTAssertEqual(cached?.name, "The Octocat")
    }

    func testRateLimitBacksOff() async {
        let http = MockHTTP()
        http.responses["https://api.github.com/users/someone"] = (Data(), 403, ["x-ratelimit-reset": "\(Int(Date().timeIntervalSince1970) + 600)"])
        let service = GitHubProfileService(client: http, paths: AppPaths(root: tempDir()))
        let first = await service.profile("someone")
        XCTAssertNil(first)
        let limited = await service.isRateLimited
        XCTAssertTrue(limited)
        _ = await service.profile("someone-else")
        XCTAssertEqual(http.requests.count, 1)
    }

    func testInvalidLoginNeverRequested() async {
        let http = MockHTTP()
        let service = GitHubProfileService(client: http, paths: AppPaths(root: tempDir()))
        let p = await service.profile("../../etc")
        XCTAssertNil(p)
        XCTAssertTrue(http.requests.isEmpty)
    }
}

// MARK: - End-to-end with the real bundled catalog

final class LaunchCatalogIntegrationTests: XCTestCase {
    func realBundle() throws -> Data {
        let url = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Skilldeck/Resources/catalog-bundle.json")
        guard let data = try? Data(contentsOf: url) else { throw XCTSkip("bundled catalog not built") }
        return data
    }

    func testRealCatalogMeetsLaunchCountsAndVerifies() throws {
        let (catalog, bad) = try CatalogStore.verify(try realBundle(), appVersion: "1.0.0")
        XCTAssertEqual(bad, [])
        let counts = Dictionary(grouping: catalog.resources, by: \.type).mapValues(\.count)
        XCTAssertGreaterThanOrEqual(catalog.resources.count, 250)
        XCTAssertGreaterThanOrEqual(counts[.agent] ?? 0, 100)
        XCTAssertGreaterThanOrEqual(counts[.skill] ?? 0, 100)
        XCTAssertGreaterThanOrEqual(counts[.prompt] ?? 0, 30)
        XCTAssertGreaterThanOrEqual(counts[.routine] ?? 0, 20)
        XCTAssertGreaterThanOrEqual(catalog.collections.count, 12)
        let index = CatalogIndex(catalog)
        for c in catalog.collections { XCTAssertEqual(index.resources(in: c).count, c.resources.count, c.id) }
        for r in catalog.resources {
            for ref in r.dependencies + r.related { XCTAssertNotNil(index.resource(ref), "\(r.id) -> \(ref)") }
            XCTAssertNotNil(index.contributor(r.author.github), r.id)
        }
    }

    /// Discover a resource, open its detail content, install it, and verify the files on disk.
    func testDiscoverOpenInstallLifecycle() throws {
        let (catalog, _) = try CatalogStore.verify(try realBundle(), appVersion: "1.0.0")
        let index = CatalogIndex(catalog)
        let engine = SearchEngine(index: index)
        let hit = try XCTUnwrap(engine.search("threat model").first { $0.type == .agent })
        XCTAssertFalse(Markdown.sections(hit.entrypointContent).isEmpty)
        let home = tempDir()
        let installer = Installer(paths: AppPaths(root: home.appendingPathComponent("support")), home: home)
        let plan = try installer.plan(resource: hit, platform: index.platformsByID["claude-code"]!, scope: .user)
        let rec = try installer.execute(plan).record
        for f in rec.files { XCTAssertEqual(try Hashing.sha256(fileAt: URL(fileURLWithPath: f.path)), f.sha256) }
        XCTAssertTrue(installer.modifiedFiles(rec).isEmpty)
        // Every skill in the catalog installs cleanly into an isolated home.
        for skill in catalog.resources where skill.type == .skill {
            _ = try installer.execute(try installer.plan(resource: skill, platform: index.platformsByID["claude-code"]!, scope: .user))
        }
        let installed = try FileManager.default.contentsOfDirectory(atPath: home.appendingPathComponent(".claude/skills").path)
        XCTAssertEqual(installed.count, catalog.resources.filter { $0.type == .skill }.count)
    }
}
