import SkilldeckCore
import SwiftUI

/// Native, safe Markdown renderer. Raw HTML is shown as text, never interpreted;
/// only https links are clickable.
struct MarkdownView: View {
    let text: String
    var blocks: [MarkdownBlock] { Markdown.blocks(text) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                BlockView(block: block)
            }
        }
        .textSelection(.enabled)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct BlockView: View {
    let block: MarkdownBlock

    var body: some View {
        switch block {
        case .heading(let level, let text):
            Text(inline(text))
                .font(level <= 1 ? .title2.weight(.bold) : level == 2 ? .title3.weight(.semibold) : .headline)
                .padding(.top, level <= 2 ? 6 : 2)
        case .paragraph(let text):
            Text(inline(text)).fixedSize(horizontal: false, vertical: true).lineSpacing(2)
        case .bulletList(let items), .numberedList(let items):
            let numbered = { if case .numberedList = block { return true } else { return false } }()
            VStack(alignment: .leading, spacing: 5) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Group {
                            if let checked = item.checkbox {
                                Image(systemName: checked ? "checkmark.square" : "square")
                            } else if numbered {
                                Text("\(i + 1).").monospacedDigit()
                            } else {
                                Text("•")
                            }
                        }
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 16, alignment: .trailing)
                        Text(inline(item.text)).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        case .code(_, let text):
            ScrollView(.horizontal, showsIndicators: false) {
                Text(text).font(.system(.callout, design: .monospaced)).padding(12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .textBackgroundColor).opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator))
        case .table(let header, let rows):
            ScrollView(.horizontal, showsIndicators: false) {
                Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                    GridRow { ForEach(Array(header.enumerated()), id: \.offset) { _, h in Text(inline(h)).font(.callout.weight(.semibold)) } }
                    Divider()
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        GridRow {
                            ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                                Text(inline(cell)).font(.callout).frame(maxWidth: 320, alignment: .leading).fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(12)
            }
            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
        case .quote(let text):
            HStack(spacing: 10) {
                Rectangle().fill(.tertiary).frame(width: 3)
                Text(inline(text)).foregroundStyle(.secondary)
            }
        case .rule:
            Divider()
        }
    }

    private func inline(_ s: String) -> AttributedString {
        var a = (try? AttributedString(markdown: s, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(s)
        for run in a.runs {
            if let link = run.link, link.scheme?.lowercased() != "https" { a[run.range].link = nil }
        }
        return a
    }
}
