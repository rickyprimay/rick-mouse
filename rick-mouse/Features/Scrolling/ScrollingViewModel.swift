//
//  ScrollingViewModel.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import Combine

@MainActor
final class ScrollingViewModel: ObservableObject {

    @Published var smoothness: ScrollSmoothness = .regular
    @Published var inertiaStrength: Double = 0.7
    @Published var invertDirection: Bool = false
    @Published var precisionScrollModifier: Bool = true
    @Published var scrollSpeed: Double = 1.0

    func loadSettings(from configuration: UserConfiguration) {
        let settings = configuration.scrollSettings
        smoothness = settings.smoothness
        inertiaStrength = settings.inertiaStrength
        invertDirection = settings.invertDirection
        precisionScrollModifier = settings.precisionScrollModifier
        scrollSpeed = settings.scrollSpeed
    }

    func saveSettings(to appState: AppState) {
        var settings = ScrollSettings()
        settings.smoothness = smoothness
        settings.inertiaStrength = inertiaStrength
        settings.invertDirection = invertDirection
        settings.precisionScrollModifier = precisionScrollModifier
        settings.scrollSpeed = scrollSpeed

        appState.configuration.scrollSettings = settings
        appState.saveConfiguration()
    }
}
