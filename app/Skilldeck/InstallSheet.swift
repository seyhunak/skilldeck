import AppKit
import SkilldeckCore
import SwiftUI

/// Install flow: choose target → see destination and conflicts → confirm → verify → result.
struct InstallSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let resource: Resource

    @State private var platformID = ""
    @State private var scope: InstallScope = .user
    @State private var projectRoot: URL?
    @State private var customRoot: URL?
    @State private var plan: InstallPlan?
    @State private var planError: String?
    @State private var replaceConfirmed = false
    @State private var result: InstallResult?
    @State private var installError: String?

    var targets: [(Platform, PlatformTarget)] {
        guard let index = model.index else { return [] }
        return Installer.installTargets(for: resource, in: index)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                TypeIcon(type: resource.type, size: 40)
                VStack(alignment: .leading) {
                    Text("Install \(resource.name)").font(.title2.weight(.semibold))
                    Text("\(resource.type.displayName) · v\(resource.version) · \(resource.files.count) file(s)").foregroundStyle(.secondary)
                }
            }
            if let result {
                successView(result)
            } else {
                form
            }
        }
        .padding(24)
        .frame(width: 640)
        .onAppear {
            if platformID.isEmpty {
                platformID = targets.first(where: { $0.0.id == model.defaultPlatform })?.0.id ?? targets.first?.0.id ?? ""
            }
            if !model.projectFolder.isEmpty { projectRoot = URL(fileURLWithPath: model.projectFolder) }
            if !model.customInstallFolder.isEmpty { customRoot = URL(fileURLWithPath: model.customInstallFolder) }
            replan()
        }
        .onChange(of: platformID) { replan() }
        .onChange(of: scope) { replan() }
        .onChange(of: projectRoot) { replan() }
        .onChange(of: customRoot) { replan() }
    }

    @ViewBuilder private var form: some View {
        if targets.isEmpty {
            Text("No installable target is registered for this resource type. Use Share & Export instead.").foregroundStyle(.secondary)
            HStack { Spacer(); Button("Close") { dismiss() }.keyboardShortcut(.cancelAction) }
        } else {
            Form {
                Picker("Install into", selection: $platformID) {
                    ForEach(targets, id: \.0.id) { p, t in Text("\(p.name) — \(t.format)").tag(p.id) }
                }
                Picker("Scope", selection: $scope) {
                    ForEach(availableScopes, id: \.self) { Text($0.displayName).tag($0) }
                }
                .pickerStyle(.segmented)
                if scope == .project { folderRow("Project folder", url: projectRoot) { projectRoot = $0; model.projectFolder = $0.path } }
                if scope == .custom { folderRow("Directory", url: customRoot) { customRoot = $0; model.customInstallFolder = $0.path } }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .frame(height: scope == .user ? 130 : 175)

            if let planError { Label(planError, systemImage: "exclamationmark.triangle").foregroundStyle(.orange) }
            if let plan { planSummary(plan) }
            if let installError { Label(installError, systemImage: "xmark.octagon").foregroundStyle(.red).textSelection(.enabled) }

            HStack {
                Text("Skilldeck only copies text files. Nothing in the package is executed.").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Cancel") { dismiss() }.keyboardShortcut(.cancelAction)
                Button(plan?.conflicts.isEmpty == false ? "Back Up and Replace" : (plan?.isReinstall == true ? "Reinstall" : "Install")) { install() }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .disabled(plan == nil || (plan?.conflicts.isEmpty == false && !replaceConfirmed))
            }
        }
    }

    private var availableScopes: [InstallScope] {
        guard let t = targets.first(where: { $0.0.id == platformID })?.1 else { return [.custom] }
        var s: [InstallScope] = []
        if t.userPath != nil { s.append(.user) }
        if t.projectPath != nil { s.append(.project) }
        s.append(.custom)
        return s
    }

    private func folderRow(_ label: String, url: URL?, set: @escaping (URL) -> Void) -> some View {
        LabeledContent(label) {
            HStack {
                Text(url?.path ?? "Not chosen").font(.callout.monospaced()).lineLimit(1).truncationMode(.middle).foregroundStyle(url == nil ? .secondary : .primary)
                Button("Choose…") {
                    let panel = NSOpenPanel()
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false
                    panel.canCreateDirectories = true
                    panel.prompt = "Choose"
                    if panel.runModal() == .OK, let u = panel.url { set(u) }
                }
            }
        }
    }

    private func planSummary(_ plan: InstallPlan) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Destination").font(.headline)
            Text(plan.primaryLocation.path).font(.callout.monospaced()).textSelection(.enabled)
            ScrollView {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(plan.files, id: \.destination) { f in
                        HStack(spacing: 6) {
                            Image(systemName: !f.exists ? "plus.circle" : f.ownedUnmodified ? "arrow.triangle.2.circlepath" : "exclamationmark.triangle.fill")
                                .foregroundStyle(!f.exists ? .green : f.ownedUnmodified ? .blue : .orange)
                            Text(f.destination.path.replacingOccurrences(of: FileManager.default.homeDirectoryForCurrentUser.path, with: "~"))
                                .font(.caption.monospaced()).lineLimit(1).truncationMode(.head)
                            Text(!f.exists ? "new" : f.ownedUnmodified ? "replace (unchanged Skilldeck install)" : "exists — conflict")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 120)
            ForEach(plan.notes, id: \.self) { Label($0, systemImage: "info.circle").font(.caption).foregroundStyle(.secondary) }
            if !plan.conflicts.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label("\(plan.conflicts.count) existing file(s) were not installed by Skilldeck or were modified since.", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Toggle("Back up the existing files to Skilldeck's Backups folder, then replace them", isOn: $replaceConfirmed)
                    Text("Or pick a different scope or directory to avoid the conflict.").font(.caption).foregroundStyle(.secondary)
                }
                .padding(10)
                .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    @ViewBuilder private func successView(_ result: InstallResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Installed and verified \(result.record.files.count) file(s).", systemImage: "checkmark.seal.fill").foregroundStyle(.green).font(.headline)
            Text(result.record.location).font(.callout.monospaced()).textSelection(.enabled)
            if let backup = result.backupLocation {
                Label("Previous files backed up to \(backup.path)", systemImage: "archivebox").font(.callout)
            }
            ForEach(plan?.notes ?? [], id: \.self) { Text($0).font(.callout).foregroundStyle(.secondary) }
            HStack {
                Button("Reveal in Finder") { model.reveal(result.record.location) }
                Spacer()
                Button("Done") { dismiss() }.keyboardShortcut(.defaultAction).buttonStyle(.borderedProminent)
            }
        }
    }

    private func replan() {
        planError = nil
        installError = nil
        replaceConfirmed = false
        if !availableScopes.contains(scope) { scope = availableScopes.first ?? .custom; return }
        do {
            plan = try model.plan(resource, platformID: platformID, scope: scope, projectRoot: projectRoot, customRoot: customRoot)
        } catch {
            plan = nil
            planError = error.localizedDescription
        }
    }

    private func install() {
        guard let plan else { return }
        do {
            result = try model.execute(plan, resolution: plan.conflicts.isEmpty ? .abort : .backupAndReplace)
        } catch {
            installError = error.localizedDescription
        }
    }
}
