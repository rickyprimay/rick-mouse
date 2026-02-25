//
//  SettingsViewModel.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {

    @Published var launchAtLogin: Bool = false
    @Published var showResetConfirmation: Bool = false

    func loadSettings(from appState: AppState) {
        launchAtLogin = appState.launchAtLoginService.isEnabled
    }

    func toggleLaunchAtLogin(appState: AppState) {
        appState.launchAtLoginService.isEnabled = launchAtLogin
        appState.configuration.launchAtLogin = launchAtLogin
        appState.saveConfiguration()
    }

    func resetConfiguration(appState: AppState) {
        appState.resetConfiguration()
        launchAtLogin = false
        showResetConfirmation = false
    }
}
