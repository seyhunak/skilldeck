import Foundation

public enum InstallError: LocalizedError, Equatable {
    case unsupported(platform: String, type: ResourceType)
    case requiresExport(String)
    case noDestination
    case conflictsUnresolved([String])
    case verificationFailed(String)
    case fileMissing(String)
    case scriptsNotAllowed

    public var errorDescription: String? {
        switch self {
        case .unsupported(let p, let t): "\(t.pluralName) cannot be installed into \(p)."
        case .requiresExport(let s): "This target is export-only: \(s)"
        case .noDestination: "Choose a destination folder first."
        case .conflictsUnresolved(let p): "Existing files would be overwritten: \(p.joined(separator: ", ")). Choose “Back up and replace” or another destination."
        case .verificationFailed(let p): "Installed file failed verification: \(p)"
        case .fileMissing(let p): "Package file is missing from the catalog: \(p)"
        case .scriptsNotAllowed: "Packages that declare scripts are never installed."
        }
    }
}

/// A file Skilldeck intends to write.
public struct PlannedFile: Hashable, Sendable {
    public var destination: URL
    public var contents: Data
    public var exists: Bool
    /// True when the existing file is one Skilldeck installed for this resource and the user has not modified it.
    public var ownedUnmodified: Bool
    public var sha256: String { Hashing.sha256(contents) }
}

public struct InstallPlan: Sendable {
    public var resource: Resource
    public var platform: Platform
    public var target: PlatformTarget
    public var scope: InstallScope
    public var root: URL
    public var primaryLocation: URL
    public var files: [PlannedFile]
    public var notes: [String]

    /// Files that exist and are not an unmodified Skilldeck install of this resource.
    public var conflicts: [PlannedFile] { files.filter { $0.exists && !$0.ownedUnmodified } }
    public var isReinstall: Bool { files.contains { $0.exists && $0.ownedUnmodified } }
}

public enum ConflictResolution: Sendable { case abort, backupAndReplace }

public struct InstallResult: Sendable {
    public var record: InstallRecord
    public var backupLocation: URL?
}

/// Plans and performs installation of catalog packages into AI tool directories.
/// Copies and organizes text files only; never executes package content.
public struct Installer: Sendable {
    public let paths: AppPaths
    public let home: URL

    public init(paths: AppPaths, home: URL = FileManager.default.homeDirectoryForCurrentUser) {
        self.paths = paths
        self.home = home
    }

    // MARK: Targets

    /// Platforms that can install (native_install) this resource type, using the catalog's compatibility registry.
    public static func installTargets(for resource: Resource, in index: CatalogIndex) -> [(Platform, PlatformTarget)] {
        index.catalog.platforms.compactMap { p in
            guard let t = p.target(for: resource.type), t.level == .nativeInstall || t.method == .copyPackage,
                  let declared = resource.compatibility(for: p.id), declared.level != .notSupported, declared.level != .unverified else { return nil }
            return (p, t)
        }
    }

    // MARK: Planning

    public func plan(resource: Resource, platform: Platform, scope: InstallScope, projectRoot: URL? = nil,
                     customRoot: URL? = nil, existing: [InstallRecord] = []) throws -> InstallPlan {
        if resource.safety.containsScripts == true { throw InstallError.scriptsNotAllowed }
        guard let target = platform.target(for: resource.type) else { throw InstallError.unsupported(platform: platform.name, type: resource.type) }
        switch target.method {
        case .exportZip, .exportOnly:
            throw InstallError.requiresExport(target.limitations ?? target.format)
        default: break
        }
        for f in resource.files { try PathSafety.validateRelative(f.path) }

        // Resolve the template path for the chosen scope.
        let template: String
        let base: URL
        switch scope {
        case .user:
            guard let p = target.userPath else { throw InstallError.unsupported(platform: platform.name, type: resource.type) }
            template = p; base = home
        case .project:
            guard let p = target.projectPath, let projectRoot else { throw InstallError.noDestination }
            template = p; base = projectRoot
        case .custom:
            guard let customRoot else { throw InstallError.noDestination }
            template = target.method == .copyPackage ? "{id}/" : "{id}.md"
            base = customRoot
        }
        let expanded = template.replacingOccurrences(of: "{id}", with: resource.id)
        let primary: URL = expanded.hasPrefix("~/") ? PathSafety.expandTilde(expanded, home: home) : base.appendingPathComponent(expanded)
        let root = primary.hasDirectoryPath || expanded.hasSuffix("/") ? primary : primary.deletingLastPathComponent()

        var planned: [(URL, Data)] = []
        var notes: [String] = []
        switch target.method {
        case .copyPackage:
            for f in resource.files {
                guard let content = f.content else { throw InstallError.fileMissing(f.path) }
                planned.append((try PathSafety.resolve(f.path, under: primary), Data(content.utf8)))
            }
        case .agentFile:
            var body = resource.entrypointContent
            let extras = resource.files.filter { $0.path != resource.entrypoint && $0.path != "manifest.yaml" }
            if !extras.isEmpty, let support = target.supportPath {
                let supportURL = PathSafety.expandTilde(support.replacingOccurrences(of: "{id}", with: resource.id), home: home)
                for f in resource.files {
                    guard let content = f.content else { throw InstallError.fileMissing(f.path) }
                    planned.append((try PathSafety.resolve(f.path, under: supportURL), Data(content.utf8)))
                }
                body += "\n\n---\nSupporting files for this agent are installed at `\(supportURL.path)`: "
                    + extras.map { "`\($0.path)`" }.joined(separator: ", ") + ".\n"
                notes.append("Supporting files are copied to \(supportURL.path).")
            }
            planned.append((primary, Data(body.utf8)))
        case .promptCommand:
            planned.append((primary, Data(Self.commandFile(for: resource).utf8)))
            notes.append("Invoke it as /\(resource.id) in \(platform.name).")
        case .routineCommand:
            planned.append((primary, Data(Self.commandFile(for: resource).utf8)))
            notes.append("Run it as /\(resource.id); the workflow still requires your approvals at each decision point.")
        case .exportZip, .exportOnly:
            break
        }
        if let lim = target.limitations { notes.append(lim) }

        let owned = existing.filter { $0.resourceID == resource.id }
        let ownedHashes = Dictionary(owned.flatMap(\.files).map { ($0.path, $0.sha256) }, uniquingKeysWith: { a, _ in a })
        let fm = FileManager.default
        let files = try planned.map { url, data -> PlannedFile in
            try PathSafety.assertNoSymlinks(from: root.deletingLastPathComponent(), to: url)
            let exists = fm.fileExists(atPath: url.path)
            var ownedUnmodified = false
            if exists, let recorded = ownedHashes[url.path], let current = try? Hashing.sha256(fileAt: url) {
                ownedUnmodified = recorded == current
            }
            return PlannedFile(destination: url, contents: data, exists: exists, ownedUnmodified: ownedUnmodified)
        }
        return InstallPlan(resource: resource, platform: platform, target: target, scope: scope, root: root,
                           primaryLocation: primary, files: files, notes: notes)
    }

    /// Slash-command / custom-prompt file for prompts and routines.
    public static func commandFile(for resource: Resource) -> String {
        let desc = resource.description.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\"", with: "'")
        var out = "---\ndescription: \"\(desc)\"\n---\n\n"
        switch resource.type {
        case .prompt:
            let prompt = Markdown.promptText(resource.entrypointContent) ?? Markdown.splitFrontmatter(resource.entrypointContent).body
            out += prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            out += "\n\nAdditional context from the user (fill any {{PLACEHOLDERS}} above from it): $ARGUMENTS\n"
        default:
            out += Markdown.splitFrontmatter(resource.entrypointContent).body.trimmingCharacters(in: .whitespacesAndNewlines)
            out += "\n\nAdditional context from the user: $ARGUMENTS\n"
        }
        return out
    }

    // MARK: Execution

    public func execute(_ plan: InstallPlan, resolution: ConflictResolution = .abort, now: Date = Date()) throws -> InstallResult {
        let conflicts = plan.conflicts
        if !conflicts.isEmpty && resolution == .abort {
            throw InstallError.conflictsUnresolved(conflicts.map { $0.destination.path })
        }
        let fm = FileManager.default
        var backup: URL?
        if !conflicts.isEmpty {
            let stamp = ISO8601DateFormatter().string(from: now).replacingOccurrences(of: ":", with: "-")
            let dir = paths.backupsDir.appendingPathComponent("\(stamp)-\(plan.resource.id)", isDirectory: true)
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
            for (i, f) in conflicts.enumerated() {
                try fm.copyItem(at: f.destination, to: dir.appendingPathComponent("\(i)-\(f.destination.lastPathComponent)"))
            }
            let manifest = conflicts.enumerated().map { "\($0.offset)-\($0.element.destination.lastPathComponent)\t\($0.element.destination.path)" }.joined(separator: "\n")
            try Data((manifest + "\n").utf8).write(to: dir.appendingPathComponent("BACKUP-INDEX.txt"))
            backup = dir
        }

        // Stage every file in a temporary directory on the same volume, then move into place.
        var written: [InstalledFile] = []
        var replacedOriginals: [(URL, URL)] = []  // (destination, temp copy of original) for rollback
        var created: [URL] = []
        let stagingRoot = plan.root.deletingLastPathComponent()
        try fm.createDirectory(at: stagingRoot, withIntermediateDirectories: true)
        let staging = try fm.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: stagingRoot, create: true)
        defer { try? fm.removeItem(at: staging) }
        do {
            for (i, f) in plan.files.enumerated() {
                let tmp = staging.appendingPathComponent("\(i).tmp")
                try f.contents.write(to: tmp, options: .atomic)
                try fm.createDirectory(at: f.destination.deletingLastPathComponent(), withIntermediateDirectories: true)
                if fm.fileExists(atPath: f.destination.path) {
                    let orig = staging.appendingPathComponent("\(i).orig")
                    try fm.copyItem(at: f.destination, to: orig)
                    replacedOriginals.append((f.destination, orig))
                    _ = try fm.replaceItemAt(f.destination, withItemAt: tmp)
                } else {
                    try fm.moveItem(at: tmp, to: f.destination)
                    created.append(f.destination)
                }
                let actual = try Hashing.sha256(fileAt: f.destination)
                guard actual == f.sha256 else { throw InstallError.verificationFailed(f.destination.path) }
                written.append(InstalledFile(path: f.destination.path, sha256: actual))
            }
        } catch {
            // Roll back: remove new files, restore replaced ones.
            for url in created { try? fm.removeItem(at: url) }
            for (dest, orig) in replacedOriginals { _ = try? fm.replaceItemAt(dest, withItemAt: orig) }
            throw error
        }

        let record = InstallRecord(id: UUID(), resourceID: plan.resource.id, resourceName: plan.resource.name,
                                   resourceType: plan.resource.type, version: plan.resource.version,
                                   contentSha256: plan.resource.contentSha256, platform: plan.platform.id,
                                   scope: plan.scope, location: plan.primaryLocation.path, files: written,
                                   installedAt: now, updatedAt: plan.isReinstall ? now : nil)
        return InstallResult(record: record, backupLocation: backup)
    }

    /// Re-hashes installed files. Returns paths that are missing or changed since installation.
    public func modifiedFiles(_ record: InstallRecord) -> [String] {
        record.files.compactMap { f in
            guard let h = try? Hashing.sha256(fileAt: URL(fileURLWithPath: f.path)) else { return f.path }
            return h == f.sha256 ? nil : f.path
        }
    }

    /// Removes files Skilldeck installed. Modified files are kept unless `force` is set.
    /// Returns the paths that were kept because the user changed them.
    @discardableResult
    public func uninstall(_ record: InstallRecord, force: Bool = false) throws -> [String] {
        let fm = FileManager.default
        let modified = Set(modifiedFiles(record))
        var kept: [String] = []
        for f in record.files {
            let url = URL(fileURLWithPath: f.path)
            guard fm.fileExists(atPath: url.path) else { continue }
            if modified.contains(f.path) && !force { kept.append(f.path); continue }
            try fm.trashOrRemove(url)
        }
        // Remove now-empty directories Skilldeck created for this package.
        let dirs = Set(record.files.map { URL(fileURLWithPath: $0.path).deletingLastPathComponent().path }).sorted { $0.count > $1.count }
        for d in dirs where (try? fm.contentsOfDirectory(atPath: d).isEmpty) == true {
            if d.hasSuffix("/" + record.resourceID) || d.contains("/\(record.resourceID)/") { try? fm.removeItem(atPath: d) }
        }
        return kept
    }

    // MARK: Export

    /// ZIP of one or more packages, each in its own folder, plus an optional index.
    public static func exportArchive(resources: [Resource], includeIndex: String? = nil) throws -> Data {
        var zip = ZipWriter()
        for r in resources.sorted(by: { $0.id < $1.id }) {
            for f in r.files.sorted(by: { $0.path < $1.path }) {
                guard let content = f.content else { throw InstallError.fileMissing(f.path) }
                try zip.add(path: "\(r.id)/\(f.path)", contents: Data(content.utf8))
            }
        }
        if let includeIndex { try zip.add(path: "INDEX.md", contents: Data(includeIndex.utf8)) }
        return zip.finalize()
    }

    /// Writes package folders into `directory` (no archive). Refuses to overwrite.
    public static func exportFolder(resource: Resource, to directory: URL) throws -> URL {
        let fm = FileManager.default
        let dest = directory.appendingPathComponent(resource.id, isDirectory: true)
        guard !fm.fileExists(atPath: dest.path) else { throw InstallError.conflictsUnresolved([dest.path]) }
        for f in resource.files {
            guard let content = f.content else { throw InstallError.fileMissing(f.path) }
            let url = try PathSafety.resolve(f.path, under: dest)
            try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Data(content.utf8).write(to: url, options: .atomic)
        }
        return dest
    }

    /// Codex has no agent package format; produce an AGENTS.md section for the user to merge.
    public static func agentsMarkdownSection(for resource: Resource) -> String {
        let body = Markdown.splitFrontmatter(resource.entrypointContent).body
        return "<!-- skilldeck:\(resource.id)@\(resource.version) -->\n" + body.trimmingCharacters(in: .whitespacesAndNewlines) + "\n<!-- /skilldeck:\(resource.id) -->\n"
    }

    /// Human-readable installation instructions for the clipboard.
    public static func instructions(for resource: Resource, in index: CatalogIndex) -> String {
        var lines = ["# Install \(resource.name) (\(resource.type.displayName) \(resource.version))", ""]
        for p in index.catalog.platforms {
            guard let t = p.target(for: resource.type), let c = resource.compatibility(for: p.id), c.level != .notSupported else { continue }
            lines.append("## \(p.name) — \(t.level.displayName)")
            lines.append("Format: \(t.format)")
            if let u = t.userPath { lines.append("User location: `\(u.replacingOccurrences(of: "{id}", with: resource.id))`") }
            if let pp = t.projectPath { lines.append("Project location: `\(pp.replacingOccurrences(of: "{id}", with: resource.id))`") }
            switch t.method {
            case .copyPackage: lines.append("Copy the package folder (\(resource.files.map(\.path).joined(separator: ", "))) to that location.")
            case .agentFile: lines.append("Save `\(resource.entrypoint)` as the agent file at that location.")
            case .promptCommand, .routineCommand: lines.append("Save the command file at that location, then invoke `/\(resource.id)`.")
            case .exportZip: lines.append("Export the package as a ZIP and upload it in the app's settings.")
            case .exportOnly: lines.append("Copy the content and paste it into the tool.")
            }
            if let l = t.limitations { lines.append("Note: \(l)") }
            lines.append("")
        }
        lines.append("Source: \(index.catalog.repository)/tree/main/\(resource.sourcePath ?? "")")
        return lines.joined(separator: "\n")
    }
}

extension FileManager {
    /// Moves to the Trash when possible so uninstalls are recoverable.
    func trashOrRemove(_ url: URL) throws {
        do { try trashItem(at: url, resultingItemURL: nil) } catch { try removeItem(at: url) }
    }
}
