//
//  RickMouseApp.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import SwiftUI
import Combine

@main
struct RickMouseApp: App {

    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(appState: appState)
        } label: {
            Image(systemName: "computermouse.fill")
        }
        .menuBarExtraStyle(.window)

        Window("Rick Mouse", id: "main-window") {
            MainView()
                .environmentObject(appState)
                .frame(
                    minWidth: AppConstants.windowWidth,
                    minHeight: AppConstants.windowHeight
                )
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(
            width: AppConstants.windowWidth,
            height: AppConstants.windowHeight
        )
        .windowResizability(.contentMinSize)
    }
}

@MainActor
final class AppState: ObservableObject {

    let permissionManager = AccessibilityPermissionManager()
    let persistenceService = PersistenceService.shared
    let launchAtLoginService = LaunchAtLoginService()
    let shortcutExecutor = ShortcutExecutor()
    let gestureEngine = GestureEngine()
    let scrollEngine = ScrollEngine()

    @Published var configuration: UserConfiguration
    @Published var interceptor: MouseEventInterceptor?

    init() {
        let config = PersistenceService.shared.loadConfiguration()
        self.configuration = config

        let interceptor = MouseEventInterceptor(
            configuration: config,
            gestureEngine: gestureEngine,
            scrollEngine: scrollEngine,
            shortcutExecutor: shortcutExecutor
        )
        self.interceptor = interceptor

        if permissionManager.isGranted {
            interceptor.start()
        }
    }

    func saveConfiguration() {
        persistenceService.saveConfiguration(configuration)
        interceptor?.configuration = configuration
        interceptor?.restart()
    }

    func resetConfiguration() {
        configuration = persistenceService.resetConfiguration()
        interceptor?.configuration = configuration
        interceptor?.restart()
    }

    func toggleEnabled() {
        configuration.isEnabled.toggle()
        if configuration.isEnabled {
            interceptor?.start()
        } else {
            interceptor?.stop()
        }
        saveConfiguration()
    }
}

struct MenuBarView: View {
    @ObservedObject var appState: AppState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "computermouse.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text(AppConstants.appName)
                    .font(.headline)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { appState.configuration.isEnabled },
                    set: { _ in appState.toggleEnabled() }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
            }

            Divider()

            HStack {
                Circle()
                    .fill(appState.configuration.isEnabled ? .green : .secondary)
                    .frame(width: 8, height: 8)
                Text(appState.configuration.isEnabled ? "Active" : "Disabled")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Divider()

            Button {
                openWindow(id: "main-window")
                NSApplication.shared.activate(ignoringOtherApps: true)
            } label: {
                Label("Open Settings", systemImage: "gear")
            }
            .buttonStyle(.plain)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit Rick Mouse", systemImage: "power")
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(width: 260)
    }
}
