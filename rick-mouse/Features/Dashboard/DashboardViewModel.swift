//
//  DashboardViewModel.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import Combine


@MainActor
final class DashboardViewModel: ObservableObject {

    @Published var isEnabled: Bool = true
    @Published var isAccessibilityGranted: Bool = false
    @Published var activeButtonMappings: Int = 0
    @Published var gesturesEnabled: Bool = true
    @Published var scrollSmoothness: ScrollSmoothness = .regular

    func update(from appState: AppState) {
        isEnabled = appState.configuration.isEnabled
        isAccessibilityGranted = appState.permissionManager.isGranted
        activeButtonMappings = appState.configuration.buttonMappings
            .filter { $0.action != .none }
            .count
        gesturesEnabled = appState.configuration.gestureSettings.gesturesEnabled
        scrollSmoothness = appState.configuration.scrollSettings.smoothness
    }
}
