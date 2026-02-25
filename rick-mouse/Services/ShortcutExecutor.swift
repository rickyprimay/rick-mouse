//
//  ShortcutExecutor.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import CoreGraphics
import Carbon.HIToolbox

final class ShortcutExecutor {

    func execute(action: MouseAction) {
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

    private func triggerMissionControl() {
        postKeyEvent(keyCode: UInt16(kVK_UpArrow), flags: .maskControl)
    }

    private func triggerAppExpose() {
        postKeyEvent(keyCode: UInt16(kVK_DownArrow), flags: .maskControl)
    }

    private func triggerLaunchpad() {
        if let source = CGEventSource(stateID: .hidSystemState) {
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0xA0, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0xA0, keyDown: false)
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }

    private func triggerShowDesktop() {
        postKeyEvent(keyCode: UInt16(kVK_F3), flags: .maskCommand)
    }

    private func triggerSmartZoom() {
        if let source = CGEventSource(stateID: .hidSystemState) {
            let event = CGEvent(
                scrollWheelEvent2Source: source,
                units: .pixel,
                wheelCount: 1,
                wheel1: 0,
                wheel2: 0,
                wheel3: 0
            )
            event?.flags = .maskControl
            event?.post(tap: .cghidEventTap)
        }
    }

    private func triggerNavigateBack() {
        postKeyEvent(keyCode: UInt16(kVK_ANSI_LeftBracket), flags: .maskCommand)
    }

    private func triggerNavigateForward() {
        postKeyEvent(keyCode: UInt16(kVK_ANSI_RightBracket), flags: .maskCommand)
    }

    private func triggerMiddleClick() {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }
        let pos = CGEvent(source: nil)?.location ?? .zero

        let down = CGEvent(
            mouseEventSource: source,
            mouseType: .otherMouseDown,
            mouseCursorPosition: pos,
            mouseButton: .center
        )
        let up = CGEvent(
            mouseEventSource: source,
            mouseType: .otherMouseUp,
            mouseCursorPosition: pos,
            mouseButton: .center
        )

        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    private func triggerSwitchDesktop(direction: GestureDirection) {
        let keyCode: UInt16 = direction == .left
            ? UInt16(kVK_LeftArrow)
            : UInt16(kVK_RightArrow)
        postKeyEvent(keyCode: keyCode, flags: .maskControl)
    }

    private func triggerKeyboardShortcut(_ shortcut: KeyShortcut) {
        postKeyEvent(
            keyCode: UInt16(shortcut.keyCode),
            flags: shortcut.modifiers.cgEventFlags
        )
    }

    private func postKeyEvent(keyCode: UInt16, flags: CGEventFlags) {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)

        keyDown?.flags = flags
        keyUp?.flags = flags

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
