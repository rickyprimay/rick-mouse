//
//  EventTapManager.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import CoreGraphics

typealias EventTapCallback = (CGEventType, CGEvent) -> Unmanaged<CGEvent>?

final class EventTapManager {

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var callback: EventTapCallback?

    private(set) var isRunning: Bool = false

    private let eventMask: CGEventMask = {
        let types: [CGEventType] = [
            .otherMouseDown,
            .otherMouseUp,
            .otherMouseDragged,
            .scrollWheel,
        ]
        return types.reduce(0) { mask, type in
            mask | (1 << type.rawValue)
        }
    }()

    func start(handler: @escaping EventTapCallback) {
        guard eventTap == nil else { return }

        self.callback = handler

        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { proxy, type, event, userInfo in
                guard let userInfo else { return Unmanaged.passUnretained(event) }
                let manager = Unmanaged<EventTapManager>.fromOpaque(userInfo).takeUnretainedValue()

                if type == .tapDisabledByUserInput || type == .tapDisabledByTimeout {
                    DispatchQueue.main.async { manager.reenable() }
                    return Unmanaged.passUnretained(event)
                }

                return manager.callback?(type, event) ?? Unmanaged.passUnretained(event)
            },
            userInfo: userInfo
        ) else {
            print("[EventTapManager] Failed to create event tap. Check Accessibility permission.")
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        guard let source = runLoopSource else {
            print("[EventTapManager] Failed to create run loop source.")
            return
        }

        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        isRunning = true
        print("[EventTapManager] Event tap started successfully.")
    }

    func stop() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        runLoopSource = nil
        eventTap = nil
        callback = nil
        isRunning = false
        print("[EventTapManager] Event tap stopped.")
    }

    func reenable() {
        guard let tap = eventTap else { return }
        if !CGEvent.tapIsEnabled(tap: tap) {
            CGEvent.tapEnable(tap: tap, enable: true)
            print("[EventTapManager] Event tap re-enabled.")
        }
    }
}
