//
//  UserConfiguration.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation

struct UserConfiguration: Codable {

    var isEnabled: Bool = true
    var launchAtLogin: Bool = false

    var buttonMappings: [ButtonMapping] = Self.defaultButtonMappings

    var scrollSettings: ScrollSettings = ScrollSettings()

    var gestureSettings: GestureSettings = GestureSettings()
}

struct ScrollSettings: Codable {
    var smoothness: ScrollSmoothness = .regular
    var inertiaStrength: Double = 0.7
    var invertDirection: Bool = false
    var precisionScrollModifier: Bool = true
    var scrollSpeed: Double = 1.0
}

enum ScrollSmoothness: String, Codable, CaseIterable, Identifiable {
    case high = "high"
    case regular = "regular"
    case off = "off"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .high: return "High"
        case .regular: return "Regular"
        case .off: return "Off"
        }
    }

    var subtitle: String {
        switch self {
        case .high: return "Trackpad-level inertia with bounce"
        case .regular: return "Responsive micro-animation"
        case .off: return "Step-based consistent scroll"
        }
    }

    var sfSymbol: String {
        switch self {
        case .high: return "water.waves"
        case .regular: return "wind"
        case .off: return "pause.circle"
        }
    }
}

struct GestureSettings: Codable {
    var gesturesEnabled: Bool = true
    var triggerButton: MouseButton = .button4

    var dragUpAction: MouseAction = .missionControl
    var dragDownAction: MouseAction = .appExpose
    var dragLeftAction: MouseAction = .switchDesktopLeft
    var dragRightAction: MouseAction = .switchDesktopRight
    var scrollUpAction: MouseAction = .showDesktop
    var scrollDownAction: MouseAction = .launchpad

    var dragThreshold: Double = 30.0
    var momentumDecay: Double = 0.92
}

extension UserConfiguration {

    static var defaultButtonMappings: [ButtonMapping] {
        [
            ButtonMapping(button: .button4, clickType: .singleClick, action: .navigateBack),
            ButtonMapping(button: .button5, clickType: .singleClick, action: .navigateForward),
            ButtonMapping(button: .middle, clickType: .singleClick, action: .middleClick),
        ]
    }
}
