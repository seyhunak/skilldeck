import Foundation

public enum CatalogError: LocalizedError, Equatable {
    case missingBundledCatalog
    case integrityFailure(String)
    case hashMismatch(expected: String, actual: String)
    case unsupportedSchema(String)
    case appTooOld(required: String)
    case notNewer(String)
    case invalidEndpoint(String)
    case network(String)
    case tooLarge(Int)

    public var errorDescription: String? {
        switch self {
        case .missingBundledCatalog: "The bundled catalog is missing from the application."
        case .integrityFailure(let d): "Catalog integrity check failed: \(d)"
        case .hashMismatch(let e, let a): "Downloaded catalog does not match its published SHA-256 (expected \(e.prefix(12))…, got \(a.prefix(12))…)."
        case .unsupportedSchema(let v): "Catalog format \(v) is not supported by this version of Skilldeck."
        case .appTooOld(let r): "This catalog requires Skilldeck \(r) or later."
        case .notNewer(let v): "Catalog \(v) is not newer than the installed catalog."
        case .invalidEndpoint(let s): "The catalog endpoint “\(s)” is not a valid HTTPS URL."
        case .network(let s): "Network error: \(s)"
        case .tooLarge(let n): "The catalog download (\(n) bytes) exceeds the size limit."
        }
    }
}

public enum CatalogSource: String, Sendable { case bundled, downloaded }

public struct LoadedCatalog: Sendable {
    public let index: CatalogIndex
    public let source: CatalogSource
    /// Resource ids whose files failed integrity verification and were excluded.
    public let quarantined: [String]
}

/// Loads, verifies, and atomically replaces the local catalog.
public struct CatalogStore: Sendable {
    public static let supportedSchemas: Set<String> = ["1.1"]
    public static let maxBundleBytes = 64 * 1024 * 1024

    public let paths: AppPaths
    public let bundledURL: URL?
    public let appVersion: String

    public init(paths: AppPaths, bundledURL: URL?, appVersion: String) {
        self.paths = paths
        self.bundledURL = bundledURL
        self.appVersion = appVersion
    }

    /// Decodes and verifies a bundle. Resources whose file hashes don't match are quarantined (removed).
    public static func verify(_ data: Data, appVersion: String) throws -> (Catalog, [String]) {
        var catalog: Catalog
        do { catalog = try Catalog.decode(data) } catch { throw CatalogError.integrityFailure("could not decode catalog: \(error.localizedDescription)") }
        guard supportedSchemas.contains(catalog.schemaVersion) else { throw CatalogError.unsupportedSchema(catalog.schemaVersion) }
        if SemVer.isNewer(catalog.minimumAppVersion, than: appVersion) { throw CatalogError.appTooOld(required: catalog.minimumAppVersion) }
        var bad: [String] = []
        for r in catalog.resources {
            var ok = Hashing.packageHash(r.files) == r.contentSha256
            for f in r.files where ok {
                guard (try? PathSafety.validateRelative(f.path)) != nil, let content = f.content,
                      Hashing.sha256(content) == f.sha256 else { ok = false; break }
            }
            if !ok { bad.append(r.id) }
        }
        if !bad.isEmpty {
            let badSet = Set(bad)
            catalog.resources.removeAll { badSet.contains($0.id) }
        }
        return (catalog, bad)
    }

    /// Prefers a verified downloaded catalog that is at least as new as the bundled one; otherwise the bundled catalog.
    public func load() throws -> LoadedCatalog {
        var bundled: (Catalog, [String])?
        if let bundledURL, let data = try? Data(contentsOf: bundledURL) {
            bundled = try? Self.verify(data, appVersion: appVersion)
        }
        if let data = try? Data(contentsOf: paths.currentCatalog), let downloaded = try? Self.verify(data, appVersion: appVersion) {
            if bundled == nil || !SemVer.isNewer(bundled!.0.catalogVersion, than: downloaded.0.catalogVersion) {
                return LoadedCatalog(index: CatalogIndex(downloaded.0), source: .downloaded, quarantined: downloaded.1)
            }
        }
        guard let bundled else { throw CatalogError.missingBundledCatalog }
        return LoadedCatalog(index: CatalogIndex(bundled.0), source: .bundled, quarantined: bundled.1)
    }

    /// Verifies `data` against `expectedSHA256`, then atomically installs it as the current catalog,
    /// keeping the previous one for rollback. On any failure the current catalog is untouched.
    @discardableResult
    public func install(bundleData data: Data, expectedSHA256: String, currentVersion: String) throws -> Catalog {
        let actual = Hashing.sha256(data)
        guard actual.lowercased() == expectedSHA256.lowercased() else { throw CatalogError.hashMismatch(expected: expectedSHA256, actual: actual) }
        let (catalog, bad) = try Self.verify(data, appVersion: appVersion)
        guard bad.isEmpty else { throw CatalogError.integrityFailure("\(bad.count) resource(s) failed verification") }
        guard SemVer.isNewer(catalog.catalogVersion, than: currentVersion) else { throw CatalogError.notNewer(catalog.catalogVersion) }

        let fm = FileManager.default
        try fm.createDirectory(at: paths.stagingDir, withIntermediateDirectories: true)
        let staged = paths.stagingDir.appendingPathComponent("catalog-bundle-\(UUID().uuidString).json")
        try data.write(to: staged, options: .atomic)
        defer { try? fm.removeItem(at: staged) }
        // Re-read what was written to make sure the disk copy is intact before swapping.
        guard Hashing.sha256(try Data(contentsOf: staged)) == actual else { throw CatalogError.integrityFailure("staged file corrupted") }

        let currentDir = paths.currentCatalog.deletingLastPathComponent()
        let previousDir = paths.previousCatalog.deletingLastPathComponent()
        try fm.createDirectory(at: currentDir, withIntermediateDirectories: true)
        try fm.createDirectory(at: previousDir, withIntermediateDirectories: true)
        if fm.fileExists(atPath: paths.currentCatalog.path) {
            if fm.fileExists(atPath: paths.previousCatalog.path) { try fm.removeItem(at: paths.previousCatalog) }
            try fm.copyItem(at: paths.currentCatalog, to: paths.previousCatalog)
            _ = try fm.replaceItemAt(paths.currentCatalog, withItemAt: staged)
        } else {
            try fm.moveItem(at: staged, to: paths.currentCatalog)
        }
        return catalog
    }

    public var canRollback: Bool { FileManager.default.fileExists(atPath: paths.previousCatalog.path) }

    /// Restores the previous downloaded catalog. If there is none, removes the downloaded catalog so the bundled one is used.
    public func rollback() throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: paths.previousCatalog.path) {
            let data = try Data(contentsOf: paths.previousCatalog)
            _ = try Self.verify(data, appVersion: appVersion)
            _ = try fm.replaceItemAt(paths.currentCatalog, withItemAt: paths.previousCatalog)
        } else if fm.fileExists(atPath: paths.currentCatalog.path) {
            try fm.removeItem(at: paths.currentCatalog)
        }
    }

    public func resetToBundled() throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: paths.catalogDir.path) { try fm.removeItem(at: paths.catalogDir) }
    }
}

// MARK: - Remote updates

public protocol HTTPClient: Sendable {
    func get(_ url: URL) async throws -> (Data, HTTPURLResponse)
}

public struct URLSessionHTTPClient: HTTPClient {
    public init() {}
    public func get(_ url: URL) async throws -> (Data, HTTPURLResponse) {
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        req.setValue("Skilldeck-macOS", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw CatalogError.network("no HTTP response") }
        return (data, http)
    }
}

public struct CatalogUpdateCheck: Sendable, Hashable {
    public var pointer: LatestPointer
    public var isNewer: Bool
    public var added: [String]
    public var updated: [String]
    public var removed: [String]
}

public struct UpdateService: Sendable {
    public static let defaultEndpoint = "https://github.com/seyhunak/skilldeck/releases/download/catalog-latest/latest.json"
    let client: HTTPClient
    let store: CatalogStore

    public init(client: HTTPClient = URLSessionHTTPClient(), store: CatalogStore) {
        self.client = client
        self.store = store
    }

    public func check(endpoint: String, current: CatalogIndex) async throws -> CatalogUpdateCheck {
        guard let url = URLSafety.safeWebURL(endpoint) else { throw CatalogError.invalidEndpoint(endpoint) }
        let (data, response) = try await client.get(url)
        guard (200..<300).contains(response.statusCode) else { throw CatalogError.network("HTTP \(response.statusCode) from \(url.host ?? "")") }
        let pointer: LatestPointer
        do { pointer = try LatestPointer.decode(data) } catch { throw CatalogError.integrityFailure("invalid latest.json") }
        guard pointer.catalogId == current.catalog.catalogId else { throw CatalogError.integrityFailure("endpoint serves a different catalog (\(pointer.catalogId))") }
        let newer = SemVer.isNewer(pointer.catalogVersion, than: current.catalog.catalogVersion)
        let changes = pointer.changes
        // Pointer changes are relative to the previous *release*; if the user skipped releases, the
        // precise diff is computed after download. Present the release's own changelog until then.
        return CatalogUpdateCheck(pointer: pointer, isNewer: newer, added: changes?.added ?? [], updated: changes?.updated ?? [], removed: changes?.removed ?? [])
    }

    /// Downloads, verifies, and installs the bundle. Returns the new catalog.
    public func apply(_ check: CatalogUpdateCheck, current: CatalogIndex) async throws -> Catalog {
        guard let url = URLSafety.safeWebURL(check.pointer.bundle.url) else { throw CatalogError.invalidEndpoint(check.pointer.bundle.url) }
        guard check.pointer.bundle.size <= CatalogStore.maxBundleBytes else { throw CatalogError.tooLarge(check.pointer.bundle.size) }
        let (data, response) = try await client.get(url)
        guard (200..<300).contains(response.statusCode) else { throw CatalogError.network("HTTP \(response.statusCode) downloading catalog") }
        guard data.count <= CatalogStore.maxBundleBytes else { throw CatalogError.tooLarge(data.count) }
        return try store.install(bundleData: data, expectedSHA256: check.pointer.bundle.sha256, currentVersion: current.catalog.catalogVersion)
    }

    /// Exact diff between two catalogs.
    public static func diff(old: Catalog, new: Catalog) -> CatalogChanges {
        let o = Dictionary(old.resources.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
        let n = Dictionary(new.resources.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
        let added = Set(n.keys).subtracting(o.keys).sorted()
        let removed = Set(o.keys).subtracting(n.keys).sorted()
        let updated = Set(n.keys).intersection(o.keys).filter { n[$0]!.version != o[$0]!.version || n[$0]!.contentSha256 != o[$0]!.contentSha256 }.sorted()
        return CatalogChanges(previousVersion: old.catalogVersion, added: added, updated: updated, removed: removed)
    }
}
