import CryptoKit
import Foundation

// MARK: - Semantic versions

public struct SemVer: Comparable, Hashable, Sendable, CustomStringConvertible {
    public let major: Int, minor: Int, patch: Int

    public init?(_ string: String) {
        let core = string.split(separator: "-").first.map(String.init) ?? string
        let parts = core.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "v")).split(separator: ".")
        guard parts.count == 3, let a = Int(parts[0]), let b = Int(parts[1]), let c = Int(parts[2]), a >= 0, b >= 0, c >= 0 else { return nil }
        major = a; minor = b; patch = c
    }

    public static func < (l: SemVer, r: SemVer) -> Bool {
        (l.major, l.minor, l.patch) < (r.major, r.minor, r.patch)
    }

    public var description: String { "\(major).\(minor).\(patch)" }

    /// True when `candidate` is a strictly newer valid version than `current`.
    public static func isNewer(_ candidate: String, than current: String) -> Bool {
        guard let c = SemVer(candidate), let k = SemVer(current) else { return false }
        return c > k
    }
}

// MARK: - Hashing

public enum Hashing {
    public static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    public static func sha256(_ string: String) -> String { sha256(Data(string.utf8)) }

    public static func sha256(fileAt url: URL) throws -> String {
        sha256(try Data(contentsOf: url))
    }

    /// Mirrors scripts/build_catalog.py content_hash(): SHA-256 over sorted "path\0sha256\n" lines.
    public static func packageHash(_ files: [ResourceFile]) -> String {
        let lines = files.sorted { $0.path < $1.path }.map { "\($0.path)\u{0}\($0.sha256)\n" }.joined()
        return sha256(lines)
    }
}

// MARK: - Path safety

public enum PathSafetyError: LocalizedError, Equatable {
    case unsafeRelativePath(String)
    case escapesRoot(String)
    case symlinkInPath(String)

    public var errorDescription: String? {
        switch self {
        case .unsafeRelativePath(let p): "Refusing unsafe package path “\(p)”."
        case .escapesRoot(let p): "Refusing to write outside the destination: “\(p)”."
        case .symlinkInPath(let p): "Refusing to write through a symbolic link at “\(p)”."
        }
    }
}

public enum PathSafety {
    /// Validates a package-relative POSIX path from untrusted catalog data.
    public static func validateRelative(_ path: String) throws {
        let comps = path.split(separator: "/", omittingEmptySubsequences: false)
        guard !path.isEmpty, !path.hasPrefix("/"), !path.hasPrefix("~"), !path.contains("\\"), !path.contains("\u{0}"),
              !comps.contains(where: { $0 == ".." || $0 == "." || $0.isEmpty }) else {
            throw PathSafetyError.unsafeRelativePath(path)
        }
    }

    /// Resolves `relative` under `root` and guarantees the result stays inside root.
    public static func resolve(_ relative: String, under root: URL) throws -> URL {
        try validateRelative(relative)
        let base = root.standardizedFileURL.path
        let target = root.appendingPathComponent(relative).standardizedFileURL
        guard target.path == base || target.path.hasPrefix(base.hasSuffix("/") ? base : base + "/") else {
            throw PathSafetyError.escapesRoot(relative)
        }
        return target
    }

    /// Throws if any existing component between root (inclusive) and url is a symbolic link.
    public static func assertNoSymlinks(from root: URL, to url: URL) throws {
        let fm = FileManager.default
        var current = url.standardizedFileURL
        let stop = root.standardizedFileURL.deletingLastPathComponent().path
        while current.path.count > stop.count {
            if let attrs = try? fm.attributesOfItem(atPath: current.path),
               (attrs[.type] as? FileAttributeType) == .typeSymbolicLink {
                throw PathSafetyError.symlinkInPath(current.path)
            }
            current = current.deletingLastPathComponent()
        }
    }

    public static func expandTilde(_ path: String, home: URL = FileManager.default.homeDirectoryForCurrentUser) -> URL {
        if path == "~" { return home }
        if path.hasPrefix("~/") { return home.appendingPathComponent(String(path.dropFirst(2))) }
        return URL(fileURLWithPath: path)
    }
}

// MARK: - ZIP writer (stored entries, no external processes)

/// Minimal ZIP archive writer using the STORE method. Pure Swift so export never
/// shells out; entries are validated with PathSafety first.
public struct ZipWriter {
    private var data = Data()
    private var central = Data()
    private var count: UInt16 = 0

    public init() {}

    public mutating func add(path: String, contents: Data) throws {
        try PathSafety.validateRelative(path)
        let name = Data(path.utf8)
        let crc = CRC32.checksum(contents)
        let offset = UInt32(data.count)
        // DOS date 1980-01-01 00:00 for reproducible archives.
        let time: UInt16 = 0, date: UInt16 = (0 << 9) | (1 << 5) | 1
        var local = Data()
        local.append(le32: 0x04034b50); local.append(le16: 20); local.append(le16: 0x0800); local.append(le16: 0)
        local.append(le16: time); local.append(le16: date); local.append(le32: crc)
        local.append(le32: UInt32(contents.count)); local.append(le32: UInt32(contents.count))
        local.append(le16: UInt16(name.count)); local.append(le16: 0)
        local.append(name)
        data.append(local); data.append(contents)

        var c = Data()
        c.append(le32: 0x02014b50); c.append(le16: 0x031E); c.append(le16: 20); c.append(le16: 0x0800); c.append(le16: 0)
        c.append(le16: time); c.append(le16: date); c.append(le32: crc)
        c.append(le32: UInt32(contents.count)); c.append(le32: UInt32(contents.count))
        c.append(le16: UInt16(name.count)); c.append(le16: 0); c.append(le16: 0); c.append(le16: 0); c.append(le16: 0)
        c.append(le32: UInt32(0o100644) << 16); c.append(le32: offset)
        c.append(name)
        central.append(c)
        count += 1
    }

    public func finalize() -> Data {
        var out = data
        let offset = UInt32(out.count)
        out.append(central)
        out.append(le32: 0x06054b50); out.append(le16: 0); out.append(le16: 0)
        out.append(le16: count); out.append(le16: count)
        out.append(le32: UInt32(central.count)); out.append(le32: offset); out.append(le16: 0)
        return out
    }
}

enum CRC32 {
    static let table: [UInt32] = (0..<256).map { i -> UInt32 in
        var c = UInt32(i)
        for _ in 0..<8 { c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1 }
        return c
    }

    static func checksum(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFF_FFFF
        for b in data { crc = table[Int((crc ^ UInt32(b)) & 0xFF)] ^ (crc >> 8) }
        return crc ^ 0xFFFF_FFFF
    }
}

extension Data {
    mutating func append(le16 v: UInt16) { Swift.withUnsafeBytes(of: v.littleEndian) { append(contentsOf: $0) } }
    mutating func append(le32 v: UInt32) { Swift.withUnsafeBytes(of: v.littleEndian) { append(contentsOf: $0) } }
}

// MARK: - URL validation

public enum URLSafety {
    /// Only https (and http for GitHub avatars fallback) URLs are opened or fetched.
    public static func safeWebURL(_ string: String?) -> URL? {
        guard let string, let url = URL(string: string), let scheme = url.scheme?.lowercased(),
              scheme == "https", url.host != nil else { return nil }
        return url
    }

    public static func isValidGitHubLogin(_ login: String) -> Bool {
        login.range(of: "^[A-Za-z0-9](?:[A-Za-z0-9]|-(?=[A-Za-z0-9])){0,38}$", options: .regularExpression) != nil
    }
}

// MARK: - Dates

public enum CatalogDate {
    public static func parse(_ string: String?) -> Date? {
        guard let string else { return nil }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "yyyy-MM-dd"
        if let d = f.date(from: String(string.prefix(10))) { return d }
        return ISO8601DateFormatter().date(from: string)
    }
}
