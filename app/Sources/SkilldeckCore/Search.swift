import Foundation

public struct SearchFilters: Hashable, Sendable {
    public var types: Set<ResourceType> = []
    public var domains: Set<String> = []
    public var useCases: Set<String> = []
    public var platforms: Set<String> = []
    /// When set, only resources with at least this compatibility level on one of `platforms` (or any platform).
    public var minimumLevel: CompatibilityLevel?
    public var authors: Set<String> = []
    public var installState: InstallStateFilter = .any
    public var featuredOnly = false

    public enum InstallStateFilter: String, CaseIterable, Sendable { case any, installed, notInstalled }

    public init() {}

    public var isEmpty: Bool {
        types.isEmpty && domains.isEmpty && useCases.isEmpty && platforms.isEmpty && minimumLevel == nil
            && authors.isEmpty && installState == .any && !featuredOnly
    }

    public var activeCount: Int {
        [!types.isEmpty, !domains.isEmpty, !useCases.isEmpty, !platforms.isEmpty, minimumLevel != nil,
         !authors.isEmpty, installState != .any, featuredOnly].filter { $0 }.count
    }
}

public enum SearchSort: String, CaseIterable, Sendable, Identifiable {
    case relevance, name, recentlyUpdated, mostReferenced, type
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .relevance: "Relevance"
        case .name: "Name"
        case .recentlyUpdated: "Recently Updated"
        case .mostReferenced: "Most Referenced"
        case .type: "Type"
        }
    }
}

public struct SearchSuggestion: Hashable, Sendable, Identifiable {
    public enum Kind: String, Sendable { case resource, tag, useCase, author, domain }
    public var kind: Kind
    public var text: String
    public var value: String
    public var id: String { "\(kind.rawValue):\(value)" }
}

/// In-memory weighted search over the local catalog. Works fully offline.
public final class SearchEngine: @unchecked Sendable {
    struct Entry {
        let resource: Resource
        let fields: [(tokens: [String], weight: Double)]
        let haystack: String
    }

    private let entries: [Entry]
    private let index: CatalogIndex

    public init(index: CatalogIndex) {
        self.index = index
        entries = index.resources.map { r in
            let domain = index.domainName(r.domain)
            let platforms = r.compatibility.filter { $0.level >= .copyPaste }.map { index.platformsByID[$0.platform]?.name ?? $0.platform }
            let fields: [([String], Double)] = [
                (Self.tokenize(r.name), 10),
                (Self.tokenize(r.tags.joined(separator: " ")), 6),
                (Self.tokenize(r.useCases.joined(separator: " ")), 5),
                (Self.tokenize(r.description), 4),
                (Self.tokenize(domain), 3),
                (Self.tokenize(r.author.name + " " + (r.author.github ?? "")), 3),
                (Self.tokenize(r.type.rawValue + " " + r.type.pluralName), 3),
                (Self.tokenize(r.purpose ?? ""), 2),
                (Self.tokenize(platforms.joined(separator: " ")), 2),
            ]
            let hay = ([r.name, r.description, r.purpose ?? "", domain, r.tags.joined(separator: " "),
                        r.useCases.joined(separator: " "), r.author.name, r.author.github ?? "", r.type.rawValue]
                       + platforms).joined(separator: " ").lowercased()
            return Entry(resource: r, fields: fields.map { (tokens: $0.0, weight: $0.1) }, haystack: hay)
        }
    }

    public static func tokenize(_ s: String) -> [String] {
        s.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
    }

    /// Relevance score for a query; 0 means no match. Every query term must match somewhere.
    func score(_ entry: Entry, terms: [String], phrase: String) -> Double {
        guard !terms.isEmpty else { return 1 }
        var total = 0.0
        for term in terms {
            var best = 0.0
            for field in entry.fields {
                for tok in field.tokens {
                    if tok == term { best = max(best, field.weight * 1.0) }
                    else if tok.hasPrefix(term) { best = max(best, field.weight * 0.7) }
                    else if term.count >= 4, tok.contains(term) { best = max(best, field.weight * 0.35) }
                }
            }
            if best == 0, entry.haystack.contains(term) { best = 0.5 }
            if best == 0 { return 0 }
            total += best
        }
        if phrase.count > 3, entry.resource.name.lowercased().contains(phrase) { total += 15 }
        return total
    }

    public func search(_ query: String, filters: SearchFilters = .init(), sort: SearchSort = .relevance,
                       installedIDs: Set<String> = []) -> [Resource] {
        let phrase = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let terms = Self.tokenize(phrase)
        var scored: [(Resource, Double)] = []
        for e in entries {
            let r = e.resource
            guard matches(r, filters: filters, installedIDs: installedIDs) else { continue }
            let s = score(e, terms: terms, phrase: phrase)
            if s > 0 { scored.append((r, s)) }
        }
        switch sort {
        case .relevance where !terms.isEmpty:
            scored.sort { $0.1 != $1.1 ? $0.1 > $1.1 : $0.0.name < $1.0.name }
        case .relevance, .name:
            scored.sort { $0.0.name.localizedCaseInsensitiveCompare($1.0.name) == .orderedAscending }
        case .recentlyUpdated:
            scored.sort { ($0.0.updated ?? "", $1.0.name) > ($1.0.updated ?? "", $0.0.name) }
        case .mostReferenced:
            scored.sort {
                let a = index.referenceCounts[$0.0.id] ?? 0, b = index.referenceCounts[$1.0.id] ?? 0
                return a != b ? a > b : $0.0.name < $1.0.name
            }
        case .type:
            scored.sort { ($0.0.type.rawValue, $0.0.name) < ($1.0.type.rawValue, $1.0.name) }
        }
        return scored.map(\.0)
    }

    public func matches(_ r: Resource, filters f: SearchFilters, installedIDs: Set<String>) -> Bool {
        if !f.types.isEmpty, !f.types.contains(r.type) { return false }
        if !f.domains.isEmpty, !f.domains.contains(r.domain) { return false }
        if !f.useCases.isEmpty, f.useCases.isDisjoint(with: r.useCases) { return false }
        if !f.authors.isEmpty, !f.authors.contains((r.author.github ?? "").lowercased()) { return false }
        if f.featuredOnly, !r.featured { return false }
        switch f.installState {
        case .any: break
        case .installed: if !installedIDs.contains(r.id) { return false }
        case .notInstalled: if installedIDs.contains(r.id) { return false }
        }
        if !f.platforms.isEmpty || f.minimumLevel != nil {
            let minimum = f.minimumLevel ?? .copyPaste
            let ok = r.compatibility.contains { c in
                (f.platforms.isEmpty || f.platforms.contains(c.platform)) && c.level >= minimum
            }
            if !ok { return false }
        }
        return true
    }

    public func suggestions(for query: String, limit: Int = 8) -> [SearchSuggestion] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard q.count >= 2 else { return [] }
        var out: [SearchSuggestion] = []
        var seen = Set<String>()
        func add(_ s: SearchSuggestion) { if seen.insert(s.id).inserted { out.append(s) } }
        for r in index.resources where r.name.lowercased().contains(q) {
            add(.init(kind: .resource, text: r.name, value: r.id))
        }
        let tags = Set(index.resources.flatMap(\.tags)).sorted()
        for t in tags where t.hasPrefix(q) || t.replacingOccurrences(of: "-", with: " ").hasPrefix(q) {
            add(.init(kind: .tag, text: t.humanized, value: t))
        }
        let ucs = Set(index.resources.flatMap(\.useCases)).sorted()
        for u in ucs where u.contains(q) || u.humanized.lowercased().contains(q) {
            add(.init(kind: .useCase, text: u.humanized, value: u))
        }
        for d in index.catalog.domains where d.name.lowercased().contains(q) {
            add(.init(kind: .domain, text: d.name, value: d.id))
        }
        for c in index.catalog.contributors where c.github.lowercased().hasPrefix(q) || c.displayName.lowercased().contains(q) {
            add(.init(kind: .author, text: "\(c.displayName) (@\(c.github))", value: c.github.lowercased()))
        }
        return Array(out.prefix(limit))
    }
}
