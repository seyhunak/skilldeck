import Foundation

/// Public GitHub profile fields Skilldeck displays. All optional: the app works without them.
public struct GitHubProfile: Codable, Hashable, Sendable {
    public var login: String
    public var name: String?
    public var bio: String?
    public var blog: String?
    public var location: String?
    public var company: String?
    public var avatarUrl: String?
    public var htmlUrl: String?
    public var publicRepos: Int?
    public var followers: Int?
    public var fetchedAt: Date?
}

/// Fetches public GitHub profiles with disk caching, TTL, rate-limit backoff, and offline fallback.
/// Never required for displaying the catalog: callers fall back to catalog contributor data.
public actor GitHubProfileService {
    public static let ttl: TimeInterval = 24 * 3600
    private let client: HTTPClient
    private let cacheDir: URL
    private let avatarDir: URL
    private var memory: [String: GitHubProfile] = [:]
    private var rateLimitedUntil: Date?
    private var inflight: [String: Task<GitHubProfile?, Never>] = [:]

    public init(client: HTTPClient = URLSessionHTTPClient(), paths: AppPaths) {
        self.client = client
        cacheDir = paths.githubCacheDir
        avatarDir = paths.avatarCacheDir
    }

    public var isRateLimited: Bool { (rateLimitedUntil ?? .distantPast) > Date() }

    public func cachedProfile(_ login: String) -> GitHubProfile? {
        let key = login.lowercased()
        if let p = memory[key] { return p }
        let url = cacheDir.appendingPathComponent("\(key).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601
        let p = try? d.decode(GitHubProfile.self, from: data)
        memory[key] = p
        return p
    }

    /// Returns a fresh-enough profile, refreshing from the API when stale and allowed. Never throws.
    public func profile(_ login: String, now: Date = Date()) async -> GitHubProfile? {
        guard URLSafety.isValidGitHubLogin(login) else { return nil }
        let key = login.lowercased()
        let cached = cachedProfile(key)
        if let cached, let at = cached.fetchedAt, now.timeIntervalSince(at) < Self.ttl { return cached }
        if let until = rateLimitedUntil, until > now { return cached }
        if let task = inflight[key] { return await task.value }
        let task = Task<GitHubProfile?, Never> { await self.fetch(key, now: now) ?? cached }
        inflight[key] = task
        let result = await task.value
        inflight[key] = nil
        return result
    }

    private func fetch(_ login: String, now: Date) async -> GitHubProfile? {
        guard let url = URL(string: "https://api.github.com/users/\(login)") else { return nil }
        do {
            let (data, response) = try await client.get(url)
            if response.statusCode == 403 || response.statusCode == 429 {
                let reset = (response.value(forHTTPHeaderField: "x-ratelimit-reset")).flatMap(TimeInterval.init).map { Date(timeIntervalSince1970: $0) }
                rateLimitedUntil = reset ?? now.addingTimeInterval(3600)
                return nil
            }
            guard (200..<300).contains(response.statusCode) else { return nil }
            let d = JSONDecoder(); d.keyDecodingStrategy = .convertFromSnakeCase
            var p = try d.decode(GitHubProfile.self, from: data)
            guard p.login.lowercased() == login else { return nil }
            p.fetchedAt = now
            p.blog = p.blog.flatMap { $0.isEmpty ? nil : ($0.hasPrefix("http") ? $0 : "https://\($0)") }
            memory[login] = p
            try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
            let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601
            try? e.encode(p).write(to: cacheDir.appendingPathComponent("\(login).json"), options: .atomic)
            return p
        } catch {
            return nil
        }
    }

    /// Avatar image bytes from the disk cache, downloading from github.com/<login>.png when missing or older than the TTL.
    public func avatarData(_ login: String, size: Int = 256, now: Date = Date()) async -> Data? {
        guard URLSafety.isValidGitHubLogin(login) else { return nil }
        let key = login.lowercased()
        let file = avatarDir.appendingPathComponent("\(key)-\(size).png")
        let fm = FileManager.default
        let cached = try? Data(contentsOf: file)
        if let attrs = try? fm.attributesOfItem(atPath: file.path), let mod = attrs[.modificationDate] as? Date,
           now.timeIntervalSince(mod) < Self.ttl * 7, cached != nil {
            return cached
        }
        guard let url = URL(string: "https://github.com/\(key).png?size=\(size)") else { return cached }
        do {
            let (data, response) = try await client.get(url)
            guard (200..<300).contains(response.statusCode), data.count < 2_000_000,
                  (response.value(forHTTPHeaderField: "Content-Type") ?? "image/").hasPrefix("image/") else { return cached }
            try? fm.createDirectory(at: avatarDir, withIntermediateDirectories: true)
            try? data.write(to: file, options: .atomic)
            return data
        } catch {
            return cached
        }
    }

    public func clearCache() {
        memory = [:]
        try? FileManager.default.removeItem(at: cacheDir)
        try? FileManager.default.removeItem(at: avatarDir)
    }
}
