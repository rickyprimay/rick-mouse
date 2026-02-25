//
//  ShortcutExecutor.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import CoreGraphics
import Carbon.HIToolbox
import AppKit

// Private Dock API — used by Mac Mouse Fix and similar tools
// This is the reliable way to trigger system features on macOS
@_silgen_name("CoreDockSendNotification")
private func CoreDockSendNotification(_ notification: CFString, _ unknown: Int32)

final class ShortcutExecutor {

    func execute(action: MouseAction) {
        print("[ShortcutExecutor] execute: \(action)")
        switch action {
        case .none:
            break

        case .missionControl:
            triggerMissionControl()

        case .appExpose:
            triggerAppExpose()

        case .launchpad:
            triggerLaunchpad()

        case .showDesktop:
            triggerShowDesktop()

        case .smartZoom:
            triggerSmartZoom()

        case .navigateBack:
            triggerNavigateBack()

        case .navigateForward:
            triggerNavigateForward()

        case .middleClick:
            triggerMiddleClick()

        case .switchDesktopLeft:
            triggerSwitchDesktop(direction: .left)

        case .switchDesktopRight:
            triggerSwitchDesktop(direction: .right)

        case .keyboardShortcut(let shortcut):
            triggerKeyboardShortcut(shortcut)
        }
    }

    // MARK: - System Actions via CoreDock Private API

    private func triggerMissionControl() {
        CoreDockSendNotification("com.apple.expose.awake" as CFString, 0)
        print("[ShortcutExecutor] CoreDock: Mission Control")
    }

    private func triggerAppExpose() {
        CoreDockSendNotification("com.apple.expose.front.awake" as CFString, 0)
        print("[ShortcutExecutor] CoreDock: App Exposé")
    }

    private func triggerLaunchpad() {
        CoreDockSendNotification("com.apple.launchpad.toggle" as CFString, 0)
        print("[ShortcutExecutor] CoreDock: Launchpad")
    }

    private func triggerShowDesktop() {
        CoreDockSendNotification("com.apple.showdesktop.awake" as CFString, 0)
        print("[ShortcutExecutor] CoreDock: Show Desktop")
    }

    // MARK: - Actions via CGEvent

    private func triggerSmartZoom() {
        let event = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 1,
            wheel1: 0,
            wheel2: 0,
            wheel3: 0
        )
        event?.flags = .maskControl
        event?.post(tap: .cgSessionEventTap)
        print("[ShortcutExecutor] SmartZoom posted")
    }


    private func triggerMiddleClick() {
        let pos = CGEvent(source: nil)?.location ?? .zero

        let down = CGEvent(
            mouseEventSource: nil,
            mouseType: .otherMouseDown,
            mouseCursorPosition: pos,
            mouseButton: .center
        )
        let up = CGEvent(
            mouseEventSource: nil,
            mouseType: .otherMouseUp,
            mouseCursorPosition: pos,
            mouseButton: .center
        )

        down?.post(tap: .cgSessionEventTap)
        usleep(5_000)
        up?.post(tap: .cgSessionEventTap)
        print("[ShortcutExecutor] MiddleClick posted")
    }

    private func triggerSwitchDesktop(direction: GestureDirection) {
        let keyCode = direction == .left ? 123 : 124 // kVK_LeftArrow / kVK_RightArrow
        runOsascript("tell application \"System Events\" to key code \(keyCode) using control down")
    }

    private func triggerNavigateBack() {
        runOsascript("tell application \"System Events\" to key code 33 using command down")
    }

    private func triggerNavigateForward() {
        runOsascript("tell application \"System Events\" to key code 30 using command down")
    }

    private func triggerKeyboardShortcut(_ shortcut: KeyShortcut) {
        var modParts: [String] = []
        if shortcut.modifiers.command { modParts.append("command down") }
        if shortcut.modifiers.option { modParts.append("option down") }
        if shortcut.modifiers.control { modParts.append("control down") }
        if shortcut.modifiers.shift { modParts.append("shift down") }
        let modString = modParts.isEmpty ? "" : " using {\(modParts.joined(separator: ", "))}"
        runOsascript("tell application \"System Events\" to key code \(shortcut.keyCode)\(modString)")
    }

    // MARK: - osascript subprocess (runs as separate process with system-level permissions)

    private func runOsascript(_ script: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", script]
        task.standardOutput = FileHandle.nullDevice
        task.standardError = FileHandle.nullDevice
        do {
            try task.run()
            print("[ShortcutExecutor] osascript: \(script)")
        } catch {
            print("[ShortcutExecutor] osascript error: \(error)")
        }
    }
}
