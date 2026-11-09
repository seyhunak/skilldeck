import Foundation

/// Lightweight, safe Markdown handling. Content is parsed into typed blocks and
/// rendered natively; raw HTML is never interpreted.
public enum MarkdownBlock: Hashable, Sendable {
    case heading(level: Int, text: String)
    case paragraph(String)
    case bulletList([ListItem])
    case numberedList([ListItem])
    case code(language: String?, text: String)
    case table(header: [String], rows: [[String]])
    case quote(String)
    case rule

    public struct ListItem: Hashable, Sendable {
        public var text: String
        public var checkbox: Bool?  // nil = plain item, false/true = task item
    }
}

public struct MarkdownSection: Hashable, Sendable, Identifiable {
    public var title: String
    public var body: String
    public var id: String { title }
}

public enum Markdown {
    /// Splits YAML frontmatter ("---\n...\n---") from the body. Frontmatter is returned as raw key/value lines.
    public static func splitFrontmatter(_ text: String) -> (frontmatter: [String: String], body: String) {
        guard text.hasPrefix("---\n"), let end = text.range(of: "\n---", range: text.index(text.startIndex, offsetBy: 4)..<text.endIndex) else {
            return ([:], text)
        }
        let raw = text[text.index(text.startIndex, offsetBy: 4)..<end.lowerBound]
        var fm: [String: String] = [:]
        for line in raw.split(separator: "\n") {
            guard let colon = line.firstIndex(of: ":") else { continue }
            let key = line[..<colon].trimmingCharacters(in: .whitespaces)
            let value = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
            if !key.isEmpty, !key.hasPrefix(" ") { fm[key] = value.trimmingCharacters(in: CharacterSet(charactersIn: "\"'")) }
        }
        var body = String(text[end.upperBound...])
        while body.hasPrefix("\n") { body.removeFirst() }
        return (fm, body)
    }

    /// The document's H1 title, if any.
    public static func title(_ text: String) -> String? {
        for line in splitFrontmatter(text).body.split(separator: "\n", omittingEmptySubsequences: false) where line.hasPrefix("# ") {
            return String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    /// Text between the H1 and the first H2 (an agent's system-prompt preamble).
    /// Length of a backtick fence opener on this line (>= 3), or nil.
    static func fenceLength(_ line: String) -> Int? {
        let t = line.trimmingCharacters(in: .whitespaces)
        let n = t.prefix(while: { $0 == "`" }).count
        return n >= 3 ? n : nil
    }

    /// Tracks nested-safe fence state: a fence of N backticks closes only on a bare run of >= N backticks.
    struct FenceTracker {
        var open: Int? = nil
        var inFence: Bool { open != nil }
        /// Returns true if the line is a fence delimiter (opening or closing).
        mutating func consume(_ line: String) -> Bool {
            guard let n = Markdown.fenceLength(line) else { return false }
            if let o = open {
                let t = line.trimmingCharacters(in: .whitespaces)
                if n >= o && t.allSatisfy({ $0 == "`" }) { open = nil; return true }
                return false
            }
            open = n
            return true
        }
    }

    public static func preamble(_ text: String) -> String {
        let body = splitFrontmatter(text).body
        var lines: [String] = []
        var started = false
        var fence = FenceTracker()
        for line in body.components(separatedBy: "\n") {
            _ = fence.consume(line)
            if !fence.inFence && line.hasPrefix("## ") { break }
            if line.hasPrefix("# ") && !started { started = true; continue }
            if started { lines.append(line) }
        }
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// H2 sections in document order, ignoring headings inside fenced code.
    public static func sections(_ text: String) -> [MarkdownSection] {
        let body = splitFrontmatter(text).body
        var result: [MarkdownSection] = []
        var current: String?
        var buf: [String] = []
        var fence = FenceTracker()
        for line in body.components(separatedBy: "\n") {
            _ = fence.consume(line)
            if !fence.inFence && line.hasPrefix("## ") {
                if let c = current { result.append(.init(title: c, body: buf.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines))) }
                current = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                buf = []
            } else if current != nil {
                buf.append(line)
            }
        }
        if let c = current { result.append(.init(title: c, body: buf.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines))) }
        return result
    }

    public static func section(_ text: String, startingWith prefix: String) -> MarkdownSection? {
        sections(text).first { $0.title.lowercased().hasPrefix(prefix.lowercased()) }
    }

    /// The first fenced code block in a string.
    public static func firstCodeBlock(_ text: String) -> String? {
        var fence = FenceTracker()
        var lines: [String] = []
        for line in text.components(separatedBy: "\n") {
            let wasIn = fence.inFence
            if fence.consume(line) {
                if wasIn { return lines.joined(separator: "\n") }
                continue
            }
            if fence.inFence { lines.append(line) }
        }
        return nil
    }

    /// For prompt packages: the copy-ready prompt from the "Prompt" section.
    public static func promptText(_ text: String) -> String? {
        guard let s = section(text, startingWith: "Prompt") else { return nil }
        return firstCodeBlock(s.body)
    }

    /// {{PLACEHOLDER}} names in order of first appearance.
    public static func placeholders(_ text: String) -> [String] {
        var seen = Set<String>(), out: [String] = []
        let regex = try! NSRegularExpression(pattern: "\\{\\{\\s*([A-Z][A-Z0-9_]*)\\s*\\}\\}")
        for m in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            if let r = Range(m.range(at: 1), in: text), seen.insert(String(text[r])).inserted { out.append(String(text[r])) }
        }
        return out
    }

    // MARK: Block parsing

    public static func blocks(_ text: String) -> [MarkdownBlock] {
        let lines = splitFrontmatter(text).body.components(separatedBy: "\n")
        var blocks: [MarkdownBlock] = []
        var i = 0
        var para: [String] = []

        func flushPara() {
            if !para.isEmpty { blocks.append(.paragraph(para.joined(separator: " "))); para = [] }
        }
        func isBullet(_ l: String) -> Bool {
            let t = l.trimmingCharacters(in: .whitespaces)
            return t.hasPrefix("- ") || t.hasPrefix("* ") || t.hasPrefix("+ ")
        }
        func isNumbered(_ l: String) -> Bool {
            l.trimmingCharacters(in: .whitespaces).range(of: "^\\d+[.)] ", options: .regularExpression) != nil
        }

        while i < lines.count {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if let n = fenceLength(trimmed) {
                flushPara()
                let lang = String(trimmed.dropFirst(n)).trimmingCharacters(in: .whitespaces)
                var code: [String] = []
                var fence = FenceTracker(); _ = fence.consume(trimmed)
                i += 1
                while i < lines.count, !fence.consume(lines[i]) { code.append(lines[i]); i += 1 }
                blocks.append(.code(language: lang.isEmpty ? nil : lang, text: code.joined(separator: "\n")))
                i += 1
                continue
            }
            if trimmed.isEmpty { flushPara(); i += 1; continue }
            if let level = headingLevel(trimmed) {
                flushPara()
                blocks.append(.heading(level: level, text: String(trimmed.drop(while: { $0 == "#" })).trimmingCharacters(in: .whitespaces)))
                i += 1; continue
            }
            if trimmed == "---" || trimmed == "***" { flushPara(); blocks.append(.rule); i += 1; continue }
            if trimmed.hasPrefix("|") {
                flushPara()
                var rows: [[String]] = []
                while i < lines.count, lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("|") {
                    let cells = splitRow(lines[i])
                    if !cells.allSatisfy({ $0.range(of: "^:?-{2,}:?$", options: .regularExpression) != nil }) { rows.append(cells) }
                    i += 1
                }
                if let header = rows.first { blocks.append(.table(header: header, rows: Array(rows.dropFirst()))) }
                continue
            }
            if trimmed.hasPrefix(">") {
                flushPara()
                var q: [String] = []
                while i < lines.count, lines[i].trimmingCharacters(in: .whitespaces).hasPrefix(">") {
                    q.append(String(lines[i].trimmingCharacters(in: .whitespaces).dropFirst()).trimmingCharacters(in: .whitespaces)); i += 1
                }
                blocks.append(.quote(q.joined(separator: " ")))
                continue
            }
            if isBullet(line) || isNumbered(line) {
                flushPara()
                let numbered = isNumbered(line)
                var items: [MarkdownBlock.ListItem] = []
                while i < lines.count {
                    let l = lines[i]
                    let t = l.trimmingCharacters(in: .whitespaces)
                    if numbered ? isNumbered(l) : isBullet(l) {
                        var content = numbered ? String(t[t.range(of: "^\\d+[.)] ", options: .regularExpression)!.upperBound...]) : String(t.dropFirst(2))
                        var box: Bool?
                        if content.hasPrefix("[ ] ") { box = false; content.removeFirst(4) }
                        else if content.lowercased().hasPrefix("[x] ") { box = true; content.removeFirst(4) }
                        items.append(.init(text: content, checkbox: box))
                        i += 1
                    } else if !t.isEmpty, l.hasPrefix("  ") || l.hasPrefix("\t"), !items.isEmpty {
                        // Continuation or nested item: fold into the previous item.
                        let nested = isBullet(l) || isNumbered(l)
                        items[items.count - 1].text += nested ? "\n• " + t.replacingOccurrences(of: "^([-*+]|\\d+[.)]) ", with: "", options: .regularExpression) : " " + t
                        i += 1
                    } else { break }
                }
                blocks.append(numbered ? .numberedList(items) : .bulletList(items))
                continue
            }
            para.append(trimmed)
            i += 1
        }
        flushPara()
        return blocks
    }

    static func headingLevel(_ line: String) -> Int? {
        let hashes = line.prefix(while: { $0 == "#" }).count
        guard (1...6).contains(hashes), line.dropFirst(hashes).first == " " else { return nil }
        return hashes
    }

    static func splitRow(_ line: String) -> [String] {
        var t = line.trimmingCharacters(in: .whitespaces)
        if t.hasPrefix("|") { t.removeFirst() }
        if t.hasSuffix("|") { t.removeLast() }
        return t.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
