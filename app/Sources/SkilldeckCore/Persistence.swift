import Foundation

/// Where Skilldeck keeps its local data. Injected so tests can use a temp dir.
public struct AppPaths: Sendable {
    public let root: URL
    public init(root: URL) { self.root = root }

    public static var `default`: AppPaths {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return AppPaths(root: base.appendingPathComponent("Skilldeck", isDirectory: true))
    }

    public var catalogDir: URL { root.appendingPathComponent("Catalog", isDirectory: true) }
    public var currentCatalog: URL { catalogDir.appendingPathComponent("current/catalog-bundle.json") }
    public var previousCatalog: URL { catalogDir.appendingPathComponent("previous/catalog-bundle.json") }
    public var stagingDir: URL { catalogDir.appendingPathComponent("staging", isDirectory: true) }
    public var libraryFile: URL { root.appendingPathComponent("library.json") }
    public var backupsDir: URL { root.appendingPathComponent("Backups", isDirectory: true) }
    public var cacheDir: URL { root.appendingPathComponent("Cache", isDirectory: true) }
    public var githubCacheDir: URL { cacheDir.appendingPathComponent("github", isDirectory: true) }
    public var avatarCacheDir: URL { cacheDir.appendingPathComponent("avatars", isDirectory: true) }
}

public struct InstalledFile: Codable, Hashable, Sendable {
    public var path: String       // absolute path on disk
    public var sha256: String
}

public struct InstallRecord: Codable, Hashable, Sendable, Identifiable {
    public var id: UUID
    public var resourceID: String
    public var resourceName: String
    public var resourceType: ResourceType
    public var version: String
    public var contentSha256: String
    public var platform: String
    public var scope: InstallScope
    public var location: String   // primary path shown to the user
    public var files: [InstalledFile]
    public var installedAt: Date
    public var updatedAt: Date?
}

public enum InstallScope: String, Codable, Sendable, CaseIterable {
    case user, project, custom
    public var displayName: String {
        switch self {
        case .user: "User (all projects)"
        case .project: "Project folder"
        case .custom: "Custom directory"
        }
    }
}

public struct UserCollection: Codable, Hashable, Sendable, Identifiable {
    public var id: UUID
    public var name: String
    public var resourceIDs: [String]
    public var createdAt: Date
}

public struct RecentView: Codable, Hashable, Sendable {
    public var resourceID: String
    public var viewedAt: Date
}

public struct UpdateHistoryEntry: Codable, Hashable, Sendable, Identifiable {
    public var id: UUID
    public var date: Date
    public var kind: String          // "catalog", "resource", "rollback"
    public var fromVersion: String?
    public var toVersion: String
    public var summary: String

    public init(id: UUID = UUID(), date: Date = Date(), kind: String, fromVersion: String?, toVersion: String, summary: String) {
        self.id = id; self.date = date; self.kind = kind; self.fromVersion = fromVersion; self.toVersion = toVersion; self.summary = summary
    }
}

public struct LibraryState: Codable, Sendable {
    public var schemaVersion = 1
    public var favorites: [String] = []
    public var recents: [RecentView] = []
    public var collections: [UserCollection] = []
    public var installs: [InstallRecord] = []
    public var updateHistory: [UpdateHistoryEntry] = []
    public init() {}
}

/// JSON-file backed store for user data (favorites, history, installs, collections).
/// Writes are atomic; a corrupt file is moved aside instead of being lost.
public final class LibraryStore: @unchecked Sendable {
    public private(set) var state: LibraryState
    private let url: URL
    private let lock = NSLock()
    public static let maxRecents = 50

    public init(url: URL) {
        self.url = url
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let s = try? decoder.decode(LibraryState.self, from: data) {
                state = s
            } else {
                try? FileManager.default.moveItem(at: url, to: url.appendingPathExtension("corrupt-\(Int(Date().timeIntervalSince1970))"))
                state = LibraryState()
            }
        } else {
            state = LibraryState()
        }
    }

    public func mutate(_ body: (inout LibraryState) -> Void) {
        lock.lock(); defer { lock.unlock() }
        body(&state)
        save()
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(state) else { return }
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data.write(to: url, options: .atomic)
    }

    // Convenience operations

    public func isFavorite(_ id: String) -> Bool { state.favorites.contains(id) }

    public func toggleFavorite(_ id: String) {
        mutate { s in
            if let i = s.favorites.firstIndex(of: id) { s.favorites.remove(at: i) } else { s.favorites.insert(id, at: 0) }
        }
    }

    public func recordView(_ id: String, at date: Date = Date()) {
        mutate { s in
            s.recents.removeAll { $0.resourceID == id }
            s.recents.insert(RecentView(resourceID: id, viewedAt: date), at: 0)
            if s.recents.count > Self.maxRecents { s.recents.removeLast(s.recents.count - Self.maxRecents) }
        }
    }

    public func clearRecents() { mutate { $0.recents = [] } }

    @discardableResult
    public func createCollection(named name: String, resourceIDs: [String] = []) -> UserCollection {
        let c = UserCollection(id: UUID(), name: name.trimmingCharacters(in: .whitespaces), resourceIDs: resourceIDs, createdAt: Date())
        mutate { $0.collections.append(c) }
        return c
    }

    public func addToCollection(_ collectionID: UUID, resourceID: String) {
        mutate { s in
            guard let i = s.collections.firstIndex(where: { $0.id == collectionID }), !s.collections[i].resourceIDs.contains(resourceID) else { return }
            s.collections[i].resourceIDs.append(resourceID)
        }
    }

    public func removeFromCollection(_ collectionID: UUID, resourceID: String) {
        mutate { s in
            guard let i = s.collections.firstIndex(where: { $0.id == collectionID }) else { return }
            s.collections[i].resourceIDs.removeAll { $0 == resourceID }
        }
    }

    public func renameCollection(_ id: UUID, to name: String) {
        mutate { s in if let i = s.collections.firstIndex(where: { $0.id == id }) { s.collections[i].name = name } }
    }

    public func deleteCollection(_ id: UUID) { mutate { $0.collections.removeAll { $0.id == id } } }

    public func upsertInstall(_ record: InstallRecord) {
        mutate { s in
            s.installs.removeAll { $0.resourceID == record.resourceID && $0.platform == record.platform && $0.location == record.location }
            s.installs.append(record)
        }
    }

    public func removeInstall(_ id: UUID) { mutate { $0.installs.removeAll { $0.id == id } } }

    public func addHistory(_ entry: UpdateHistoryEntry) { mutate { $0.updateHistory.insert(entry, at: 0) } }

    public func resetAll() { mutate { $0 = LibraryState() } }
}
