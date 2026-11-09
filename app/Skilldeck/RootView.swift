import SkilldeckCore
import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        @Bindable var model = model
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 230, max: 300)
        } detail: {
            NavigationStack(path: $model.path) {
                Group {
                    if let error = model.loadError {
                        EmptyStateView(title: "Catalog unavailable", symbol: "exclamationmark.triangle", message: error)
                    } else if model.index == nil {
                        ProgressView("Loading catalog…")
                    } else {
                        content(for: model.selection ?? .discover)
                    }
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .resource(let id): ResourceDetailView(resourceID: id)
                    case .contributor(let login): ContributorProfileView(login: login)
                    case .collection(let id): CollectionDetailView(collectionID: id)
                    case .userCollection(let id): UserCollectionView(collectionID: id)
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = model.toast {
                ToastView(toast: toast).padding(.bottom, 20).transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: model.toast)
    }

    @ViewBuilder
    private func content(for item: SidebarItem) -> some View {
        switch item {
        case .discover: DiscoverView()
        case .all: ResourceBrowserView(title: "All Resources", fixedType: nil)
        case .type(let t): ResourceBrowserView(title: t.pluralName, fixedType: t)
        case .collections: CollectionsView()
        case .contributors: ContributorsView()
        case .installed: InstalledView()
        case .updates: UpdatesView()
        case .favorites: FavoritesView()
        case .settings: SettingsView().navigationTitle("Settings")
        case .userCollection(let id): UserCollectionView(collectionID: id)
        }
    }
}

struct SidebarView: View {
    @Environment(AppModel.self) private var model
    @State private var newCollectionName = ""
    @State private var showingNewCollection = false

    var body: some View {
        let stats = model.index?.catalog.stats?.byType ?? [:]
        let updates = model.installsWithUpdates.count + (model.updateCheck?.isNewer == true ? 1 : 0)
        List(selection: Binding(get: { model.selection }, set: { if let v = $0 { model.select(v) } })) {
            Section {
                row("Discover", "sparkles", .discover, count: model.newResourceIDs.isEmpty ? nil : model.newResourceIDs.count)
                row("All Resources", "square.grid.2x2", .all, count: model.index?.resources.count)
            }
            Section("Library") {
                ForEach([ResourceType.agent, .skill, .prompt, .routine], id: \.self) { t in
                    row(t.pluralName, t.symbol, .type(t), count: stats[t.rawValue])
                }
                row("Collections", "rectangle.stack", .collections, count: model.index?.catalog.collections.count)
                row("Contributors", "person.2", .contributors, count: model.index?.catalog.contributors.count)
            }
            Section("My Skilldeck") {
                row("Installed", "externaldrive.badge.checkmark", .installed, count: model.library.installs.count)
                row("Updates", "arrow.down.circle", .updates, count: updates == 0 ? nil : updates)
                row("Favorites", "star", .favorites, count: model.library.favorites.count)
                Label("Settings", systemImage: "gearshape").tag(SidebarItem.settings)
            }
            Section {
                ForEach(model.library.collections) { c in
                    Label(c.name, systemImage: "folder")
                        .badge(c.resourceIDs.count)
                        .tag(SidebarItem.userCollection(c.id))
                        .contextMenu {
                            Button("Delete Collection", role: .destructive) {
                                if model.selection == .userCollection(c.id) { model.select(.discover) }
                                model.deleteCollection(c.id)
                            }
                        }
                }
            } header: {
                HStack {
                    Text("My Collections")
                    Spacer()
                    Button { showingNewCollection = true } label: { Image(systemName: "plus") }
                        .buttonStyle(.plain).help("New Collection")
                }
            }
        }
        .listStyle(.sidebar)
        .alert("New Collection", isPresented: $showingNewCollection) {
            TextField("Name", text: $newCollectionName)
            Button("Create") {
                let name = newCollectionName.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty { let c = model.createCollection(name); model.select(.userCollection(c.id)) }
                newCollectionName = ""
            }
            Button("Cancel", role: .cancel) { newCollectionName = "" }
        }
    }

    private func row(_ title: String, _ symbol: String, _ tag: SidebarItem, count: Int?) -> some View {
        Label(title, systemImage: symbol).badge(count ?? 0).tag(tag)
    }
}
