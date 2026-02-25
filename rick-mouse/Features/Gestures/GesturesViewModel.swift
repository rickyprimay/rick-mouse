//
//  GesturesViewModel.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import Combine

@MainActor
final class GesturesViewModel: ObservableObject {

    @Published var gesturesEnabled: Bool = true
    @Published var triggerButton: MouseButton = .button4
    @Published var dragThreshold: Double = 30.0
    @Published var momentumDecay: Double = 0.92

    @Published var dragUpAction: MouseAction = .missionControl
    @Published var dragDownAction: MouseAction = .appExpose
    @Published var dragLeftAction: MouseAction = .switchDesktopLeft
    @Published var dragRightAction: MouseAction = .switchDesktopRight
    @Published var scrollUpAction: MouseAction = .showDesktop
    @Published var scrollDownAction: MouseAction = .launchpad

    func loadSettings(from configuration: UserConfiguration) {
        let settings = configuration.gestureSettings
        gesturesEnabled = settings.gesturesEnabled
        triggerButton = settings.triggerButton
        dragThreshold = settings.dragThreshold
        momentumDecay = settings.momentumDecay
        dragUpAction = settings.dragUpAction
        dragDownAction = settings.dragDownAction
        dragLeftAction = settings.dragLeftAction
        dragRightAction = settings.dragRightAction
        scrollUpAction = settings.scrollUpAction
        scrollDownAction = settings.scrollDownAction
    }

    func saveSettings(to appState: AppState) {
        var settings = GestureSettings()
        settings.gesturesEnabled = gesturesEnabled
        settings.triggerButton = triggerButton
        settings.dragThreshold = dragThreshold
        settings.momentumDecay = momentumDecay
        settings.dragUpAction = dragUpAction
        settings.dragDownAction = dragDownAction
        settings.dragLeftAction = dragLeftAction
        settings.dragRightAction = dragRightAction
        settings.scrollUpAction = scrollUpAction
        settings.scrollDownAction = scrollDownAction

        appState.configuration.gestureSettings = settings
        appState.saveConfiguration()
    }
}
