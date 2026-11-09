import AppKit
import SkilldeckCore
import SwiftUI

@main
struct SkilldeckApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup("Skilldeck", id: "main") {
            RootView()
                .environment(model)
                .frame(minWidth: 980, minHeight: 620)
                .onOpenURL { model.handleDeepLink($0) }
                .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
                .task { await model.runUpdateLoop() }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                    Task { await model.backgroundUpdateIfDue() }
                }
        }
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(after: .sidebar) {
                Button("Search Library") { model.searchFocusRequest += 1 }
                    .keyboardShortcut("k", modifiers: .command)
            }
            CommandMenu("Library") {
                Button("Discover") { model.select(.discover) }.keyboardShortcut("1", modifiers: .command)
                Button("All Resources") { model.select(.all) }.keyboardShortcut("2", modifiers: .command)
                Button("Installed") { model.select(.installed) }.keyboardShortcut("3", modifiers: .command)
                Button("Favorites") { model.select(.favorites) }.keyboardShortcut("4", modifiers: .command)
                Divider()
                Button("Check for Catalog Updates…") { Task { await model.checkForUpdates(userInitiated: true); model.select(.updates) } }
                    .keyboardShortcut("u", modifiers: [.command, .shift])
                Button("Export Complete Catalog…") { model.exportCatalog() }
                Divider()
                Button("Back") { if !model.path.isEmpty { model.path.removeLast() } }
                    .keyboardShortcut("[", modifiers: .command)
                    .disabled(model.path.isEmpty)
            }
        }

        Settings {
            SettingsView()
                .environment(model)
                .frame(width: 620, height: 520)
        }
    }
}
