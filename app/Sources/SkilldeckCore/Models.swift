import Foundation

// Typed models for the generated catalog (dist/catalog-bundle.json, format 1.1).
// Decoding uses snake_case keys from the Python builder.

public enum ResourceType: String, Codable, CaseIterable, Sendable, Identifiable {
    case agent, skill, prompt, routine, instruction
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .agent: "Agent"
        case .skill: "Skill"
        case .prompt: "Prompt"
        case .routine: "Routine"
        case .instruction: "Instruction"
        }
    }
    public var pluralName: String { displayName + "s" }
    public var entrypoint: String {
        switch self {
        case .agent: "agent.md"
        case .skill: "SKILL.md"
        case .prompt: "prompt.md"
        case .routine: "routine.md"
        case .instruction: "instructions.md"
        }
    }
}

public enum CompatibilityLevel: String, Codable, CaseIterable, Sendable, Comparable {
    case notSupported = "not_supported"
    case unverified
    case copyPaste = "copy_paste"
    case genericExport = "generic_export"
    case fileExport = "file_export"
    case nativeImport = "native_import"
    case nativeInstall = "native_install"

    var rank: Int { Self.allCases.firstIndex(of: self) ?? 0 }
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rank < rhs.rank }

    public var displayName: String {
        switch self {
        case .notSupported: "Not supported"
        case .unverified: "Unverified"
        case .copyPaste: "Copy & paste"
        case .genericExport: "Export"
        case .fileExport: "File export"
        case .nativeImport: "Import"
        case .nativeInstall: "Install"
        }
    }
}

public struct Author: Codable, Hashable, Sendable {
    public var name: String
    public var github: String?
    public var url: String?
}

public struct Compatibility: Codable, Hashable, Sendable {
    public var platform: String
    public var level: CompatibilityLevel
    public var resourceTypes: [String]?
    public var notes: String?
}

public struct Safety: Codable, Hashable, Sendable {
    public var containsScripts: Bool?
    public var networkAccess: Bool?
    public var handlesSensitiveData: Bool?
    public var professionalAdviceDisclaimer: Bool?
    public var notes: String?
}

public struct ResourceFile: Codable, Hashable, Sendable {
    public var path: String
    public var size: Int
    public var sha256: String
    public var content: String?
}

public struct PackageInfo: Codable, Hashable, Sendable {
    public var filename: String
    public var size: Int
    public var sha256: String
    public var url: String
}

public struct Resource: Codable, Hashable, Sendable, Identifiable {
    public var id: String
    public var type: ResourceType
    public var name: String
    public var description: String
    public var purpose: String?
    public var version: String
    public var license: String
    public var domain: String
    public var useCases: [String]
    public var tags: [String]
    public var author: Author
    public var created: String?
    public var updated: String?
    public var featured: Bool
    public var dependencies: [String]
    public var related: [String]
    public var compatibility: [Compatibility]
    public var safety: Safety
    public var tested: Bool?
    public var changelog: [String]?
    public var entrypoint: String
    public var collections: [String]
    public var sourcePath: String?
    public var files: [ResourceFile]
    public var contentSha256: String
    public var package: PackageInfo?
    public var searchText: String?

    public var entrypointContent: String {
        files.first(where: { $0.path == entrypoint })?.content ?? ""
    }

    public func file(_ path: String) -> ResourceFile? { files.first { $0.path == path } }

    public func compatibility(for platform: String) -> Compatibility? {
        compatibility.first { $0.platform == platform }
    }
}

public struct SocialLink: Codable, Hashable, Sendable {
    public var label: String
    public var url: String
}

public struct Contributor: Codable, Hashable, Sendable, Identifiable {
    public var github: String
    public var displayName: String
    public var bio: String?
    public var website: String?
    public var location: String?
    public var socialLinks: [SocialLink]
    public var avatarUrl: String
    public var profileUrl: String
    public var hasProfile: Bool
    public var resourceIds: [String]
    public var resourceCount: Int
    public var countsByType: [String: Int]
    public var domains: [String]
    public var firstPublished: String?
    public var lastUpdated: String?
    public var featuredResourceIds: [String]
    public var id: String { github.lowercased() }
}

public struct CollectionItem: Codable, Hashable, Sendable {
    public var id: String
    public var step: Int?
    public var note: String?
}

public struct ResourceCollection: Codable, Hashable, Sendable, Identifiable {
    public var id: String
    public var title: String
    public var description: String
    public var audience: String
    public var useCases: [String]
    public var symbol: String
    public var accent: String
    public var featured: Bool?
    public var resources: [CollectionItem]
}

public struct Domain: Codable, Hashable, Sendable, Identifiable {
    public var id: String
    public var name: String
    public var symbol: String
    public var useCases: [String]
}

public struct PlatformTarget: Codable, Hashable, Sendable {
    public var resourceType: ResourceType
    public var level: CompatibilityLevel
    public var format: String
    public var userPath: String?
    public var projectPath: String?
    public var supportPath: String?
    public var method: InstallMethod
    public var limitations: String?
}

public enum InstallMethod: String, Codable, Sendable {
    case copyPackage = "copy_package"
    case agentFile = "agent_file"
    case promptCommand = "prompt_command"
    case routineCommand = "routine_command"
    case exportZip = "export_zip"
    case exportOnly = "export_only"
}

public struct Platform: Codable, Hashable, Sendable, Identifiable {
    public var id: String
    public var name: String
    public var verifiedOn: String?
    public var documentation: String?
    public var targets: [PlatformTarget]

    public func target(for type: ResourceType) -> PlatformTarget? { targets.first { $0.resourceType == type } }
}

public struct CatalogChanges: Codable, Hashable, Sendable {
    public var previousVersion: String?
    public var added: [String]
    public var updated: [String]
    public var removed: [String]
}

public struct CatalogStats: Codable, Hashable, Sendable {
    public var byType: [String: Int]
    public var byDomain: [String: Int]
}

public struct Catalog: Codable, Sendable {
    public var schemaVersion: String
    public var catalogId: String
    public var name: String
    public var description: String
    public var catalogVersion: String
    public var generatedAt: String
    public var minimumAppVersion: String
    public var repository: String
    public var resourcesCount: Int
    public var contributorsCount: Int
    public var collectionsCount: Int
    public var stats: CatalogStats?
    public var changes: CatalogChanges?
    public var domains: [Domain]
    public var platforms: [Platform]
    public var resources: [Resource]
    public var contributors: [Contributor]
    public var collections: [ResourceCollection]

    public static func decode(_ data: Data) throws -> Catalog {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Catalog.self, from: data)
    }
}

/// Small release pointer (latest.json) polled for updates.
public struct LatestPointer: Codable, Sendable, Hashable {
    public struct Asset: Codable, Sendable, Hashable {
        public var url: String
        public var sha256: String
        public var size: Int
    }
    public var schemaVersion: String
    public var catalogId: String
    public var catalogVersion: String
    public var generatedAt: String
    public var minimumAppVersion: String
    public var resourcesCount: Int
    public var bundle: Asset
    public var index: Asset?
    public var releaseNotesUrl: String?
    public var changes: CatalogChanges?

    public static func decode(_ data: Data) throws -> LatestPointer {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(LatestPointer.self, from: data)
    }
}

/// Fast lookup wrapper around a decoded catalog.
public final class CatalogIndex: @unchecked Sendable {
    public let catalog: Catalog
    public let resourcesByID: [String: Resource]
    public let contributorsByLogin: [String: Contributor]
    public let collectionsByID: [String: ResourceCollection]
    public let domainsByID: [String: Domain]
    public let platformsByID: [String: Platform]
    /// Number of times each resource is referenced by others (related, dependencies, collections).
    public let referenceCounts: [String: Int]

    public init(_ catalog: Catalog) {
        self.catalog = catalog
        resourcesByID = Dictionary(catalog.resources.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
        contributorsByLogin = Dictionary(catalog.contributors.map { ($0.github.lowercased(), $0) }, uniquingKeysWith: { a, _ in a })
        collectionsByID = Dictionary(catalog.collections.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
        domainsByID = Dictionary(catalog.domains.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
        platformsByID = Dictionary(catalog.platforms.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
        var counts: [String: Int] = [:]
        for r in catalog.resources {
            for ref in r.related + r.dependencies { counts[ref, default: 0] += 1 }
            counts[r.id, default: 0] += r.collections.count
        }
        referenceCounts = counts
    }

    public var resources: [Resource] { catalog.resources }
    public func resource(_ id: String) -> Resource? { resourcesByID[id] }
    public func contributor(_ login: String?) -> Contributor? {
        guard let login else { return nil }
        return contributorsByLogin[login.lowercased()]
    }
    public func domainName(_ id: String) -> String { domainsByID[id]?.name ?? id }
    public func resources(in collection: ResourceCollection) -> [Resource] {
        collection.resources.compactMap { resourcesByID[$0.id] }
    }
    public func resources(by contributor: Contributor) -> [Resource] {
        contributor.resourceIds.compactMap { resourcesByID[$0] }
    }
    /// Related resources in both directions, de-duplicated, dependencies first.
    public func relatedResources(for resource: Resource) -> [Resource] {
        var seen = Set<String>([resource.id])
        var out: [Resource] = []
        for id in resource.dependencies + resource.related {
            if seen.insert(id).inserted, let r = resourcesByID[id] { out.append(r) }
        }
        for r in catalog.resources where (r.related.contains(resource.id) || r.dependencies.contains(resource.id)) {
            if seen.insert(r.id).inserted { out.append(r) }
        }
        return out
    }
}

public extension String {
    /// "code-review" -> "Code Review"
    var humanized: String {
        split(separator: "-").map { word in
            let w = String(word)
            let upper: Set<String> = ["ai", "ml", "llm", "api", "sql", "seo", "ux", "bi", "prd", "kpi", "okr", "rag", "mcp", "aml", "kyc", "fpa", "dcf", "sop", "ci", "cd"]
            return upper.contains(w) ? w.uppercased() : w.prefix(1).uppercased() + w.dropFirst()
        }.joined(separator: " ")
    }
}
