import AppKit
import SkilldeckCore
import SwiftUI

// MARK: - Type styling

extension ResourceType {
    var symbol: String {
        switch self {
        case .agent: "person.crop.square.filled.and.at.rectangle"
        case .skill: "wand.and.stars"
        case .prompt: "text.bubble"
        case .routine: "list.bullet.clipboard"
        case .instruction: "doc.plaintext"
        }
    }
    var tint: Color {
        switch self {
        case .agent: .indigo
        case .skill: .teal
        case .prompt: .orange
        case .routine: .pink
        case .instruction: .gray
        }
    }
}

extension ResourceCollection {
    var tint: Color { Color.accent(named: accent) }
}

extension Color {
    static func accent(named name: String) -> Color {
        switch name {
        case "blue": .blue
        case "purple": .purple
        case "pink": .pink
        case "red": .red
        case "orange": .orange
        case "yellow": .yellow
        case "green": .green
        case "mint": .mint
        case "teal": .teal
        case "cyan": .cyan
        case "indigo": .indigo
        case "brown": .brown
        default: .gray
        }
    }
}

// MARK: - Small components

struct TypeBadge: View {
    let type: ResourceType
    var compact = false
    var body: some View {
        Label(type.displayName, systemImage: type.symbol)
            .labelStyle(.titleAndIcon)
            .font(compact ? .caption2.weight(.semibold) : .caption.weight(.semibold))
            .foregroundStyle(type.tint)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(type.tint.opacity(0.12), in: Capsule())
    }
}

struct TypeIcon: View {
    let type: ResourceType
    var size: CGFloat = 34
    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
            .fill(type.tint.gradient.opacity(0.9))
            .frame(width: size, height: size)
            .overlay(Image(systemName: type.symbol).font(.system(size: size * 0.45, weight: .medium)).foregroundStyle(.white))
            .accessibilityHidden(true)
    }
}

struct TagChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(.quaternary.opacity(0.6), in: Capsule())
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 400
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > width, x > 0 { x = 0; y += rowH + spacing; rowH = 0 }
            x += sz.width + spacing; rowH = max(rowH, sz.height)
        }
        return CGSize(width: width, height: y + rowH)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            s.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += sz.width + spacing; rowH = max(rowH, sz.height)
        }
    }
}

/// GitHub avatar with disk cache and initials fallback (works offline).
struct AvatarView: View {
    @Environment(AppModel.self) private var model
    let login: String?
    let name: String
    var size: CGFloat = 20
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image).resizable().scaledToFill()
            } else {
                Circle().fill(Color.secondary.opacity(0.2))
                    .overlay(Text(initials).font(.system(size: size * 0.4, weight: .semibold)).foregroundStyle(.secondary))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(.separator, lineWidth: 0.5))
        .task(id: login) {
            guard let login, model.fetchGitHubProfiles else { return }
            if let data = await model.github.avatarData(login, size: size > 64 ? 256 : 96) { image = NSImage(data: data) }
        }
        .accessibilityLabel("Avatar of \(name)")
    }

    private var initials: String {
        name.split(separator: " ").prefix(2).compactMap { $0.first.map(String.init) }.joined().uppercased()
    }
}

struct AuthorButton: View {
    @Environment(AppModel.self) private var model
    let author: Author
    var body: some View {
        Button {
            if let gh = author.github { model.open(.contributor(gh.lowercased())) }
        } label: {
            HStack(spacing: 5) {
                AvatarView(login: author.github, name: author.name, size: 16)
                Text(author.name).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .help(author.github.map { "Open @\($0)'s profile" } ?? author.name)
    }
}

struct CompatibilityStrip: View {
    @Environment(AppModel.self) private var model
    let resource: Resource
    var body: some View {
        HStack(spacing: 4) {
            ForEach(resource.compatibility.filter { $0.level >= .nativeImport }, id: \.platform) { c in
                Text(model.index?.platformsByID[c.platform]?.name.replacingOccurrences(of: "OpenAI ", with: "").replacingOccurrences(of: " / claude.ai", with: "") ?? c.platform)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 5).padding(.vertical, 1)
                    .overlay(Capsule().strokeBorder(.separator))
                    .help("\(c.level.displayName) supported")
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String?
    var action: (() -> Void)?
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.title3.weight(.semibold))
                if let subtitle { Text(subtitle).font(.callout).foregroundStyle(.secondary) }
            }
            Spacer()
            if let action { Button("See All", action: action).buttonStyle(.link) }
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let symbol: String
    let message: String
    var body: some View {
        ContentUnavailableView(title, systemImage: symbol, description: Text(message))
    }
}

struct ToastView: View {
    let toast: Toast
    var body: some View {
        Label(toast.message, systemImage: toast.isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
            .font(.callout.weight(.medium))
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(.regularMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.separator))
            .foregroundStyle(toast.isError ? .red : .primary)
            .shadow(radius: 8, y: 2)
    }
}
