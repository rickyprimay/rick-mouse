//
//  MouseAction.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import Carbon.HIToolbox


enum MouseAction: Codable, Hashable, Identifiable {
    case none
    case missionControl
    case appExpose
    case launchpad
    case showDesktop
    case smartZoom
    case navigateBack
    case navigateForward
    case middleClick
    case switchDesktopLeft
    case switchDesktopRight
    case keyboardShortcut(KeyShortcut)

    var id: String {
        switch self {
        case .none: return "none"
        case .missionControl: return "mission_control"
        case .appExpose: return "app_expose"
        case .launchpad: return "launchpad"
        case .showDesktop: return "show_desktop"
        case .smartZoom: return "smart_zoom"
        case .navigateBack: return "navigate_back"
        case .navigateForward: return "navigate_forward"
        case .middleClick: return "middle_click"
        case .switchDesktopLeft: return "switch_desktop_left"
        case .switchDesktopRight: return "switch_desktop_right"
        case .keyboardShortcut(let shortcut): return "shortcut_\(shortcut.id)"
        }
    }

    var displayName: String {
        switch self {
        case .none: return "None"
        case .missionControl: return "Mission Control"
        case .appExpose: return "App Exposé"
        case .launchpad: return "Launchpad"
        case .showDesktop: return "Show Desktop"
        case .smartZoom: return "Smart Zoom"
        case .navigateBack: return "Back"
        case .navigateForward: return "Forward"
        case .middleClick: return "Middle Click"
        case .switchDesktopLeft: return "Switch Desktop Left"
        case .switchDesktopRight: return "Switch Desktop Right"
        case .keyboardShortcut(let shortcut): return shortcut.displayName
        }
    }

    var sfSymbol: String {
        switch self {
        case .none: return "nosign"
        case .missionControl: return "rectangle.3.group"
        case .appExpose: return "rectangle.stack"
        case .launchpad: return "square.grid.3x3"
        case .showDesktop: return "menubar.dock.rectangle"
        case .smartZoom: return "plus.magnifyingglass"
        case .navigateBack: return "chevron.left"
        case .navigateForward: return "chevron.right"
        case .middleClick: return "computermouse.fill"
        case .switchDesktopLeft: return "chevron.left.2"
        case .switchDesktopRight: return "chevron.right.2"
        case .keyboardShortcut: return "command"
        }
    }

    static var predefined: [MouseAction] {
        [
            .none, .missionControl, .appExpose, .launchpad,
            .showDesktop, .smartZoom, .navigateBack, .navigateForward,
            .middleClick, .switchDesktopLeft, .switchDesktopRight
        ]
    }
}

struct KeyShortcut: Codable, Hashable, Identifiable {
    let id: String
    let keyCode: Int
    let modifiers: ModifierFlags
    let displayName: String

    struct ModifierFlags: Codable, Hashable {
        var command: Bool = false
        var option: Bool = false
        var control: Bool = false
        var shift: Bool = false

        var cgEventFlags: CGEventFlags {
            var flags: CGEventFlags = []
            if command { flags.insert(.maskCommand) }
            if option { flags.insert(.maskAlternate) }
            if control { flags.insert(.maskControl) }
            if shift { flags.insert(.maskShift) }
            return flags
        }

        var description: String {
            var parts: [String] = []
            if control { parts.append("⌃") }
            if option { parts.append("⌥") }
            if shift { parts.append("⇧") }
            if command { parts.append("⌘") }
            return parts.joined()
        }
    }
}

struct ButtonMapping: Codable, Hashable, Identifiable {
    var id: String { "\(button.rawValue)_\(clickType.rawValue)" }
    let button: MouseButton
    let clickType: ClickType
    var action: MouseAction
}
