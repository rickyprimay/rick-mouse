//
//  EventTapManager.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import CoreGraphics
import Combine

typealias EventTapCallback = (CGEventType, CGEvent) -> CGEvent?

final class EventTapManager {

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var callback: EventTapCallback?
    private var recoveryTimer: Timer?

    private(set) var isRunning: Bool = false

    private let eventMask: CGEventMask = {
        let types: [CGEventType] = [
            .otherMouseDown,
            .otherMouseUp,
            .otherMouseDragged,
            .scrollWheel,
            .leftMouseDown,
            .leftMouseUp,
            .rightMouseDown,
            .rightMouseUp,
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
            callback: eventTapCallbackFunction,
            userInfo: userInfo
        ) else {
            print("[EventTapManager] Failed to create event tap. Accessibility permission may not be granted.")
            scheduleRecovery()
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
        recoveryTimer?.invalidate()
        recoveryTimer = nil

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
        guard let tap = eventTap else {
            scheduleRecovery()
            return
        }

        if !CGEvent.tapIsEnabled(tap: tap) {
            CGEvent.tapEnable(tap: tap, enable: true)
            print("[EventTapManager] Event tap re-enabled.")
        }
    }

    private func scheduleRecovery() {
        recoveryTimer?.invalidate()
        recoveryTimer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.eventTapRecoveryInterval,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            if self.eventTap == nil, let cb = self.callback {
                self.start(handler: cb)
            }
            if self.isRunning {
                self.recoveryTimer?.invalidate()
                self.recoveryTimer = nil
            }
        }
    }

    fileprivate func handleEvent(type: CGEventType, event: CGEvent) -> CGEvent? {
        return callback?(type, event) ?? event
    }
}

private func eventTapCallbackFunction(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else { return Unmanaged.passUnretained(event) }

    let manager = Unmanaged<EventTapManager>.fromOpaque(userInfo).takeUnretainedValue()

    if type == .tapDisabledByUserInput || type == .tapDisabledByTimeout {
        DispatchQueue.main.async {
            manager.reenable()
        }
        return Unmanaged.passUnretained(event)
    }

    if let modifiedEvent = manager.handleEvent(type: type, event: event) {
        let originalPtr = Unmanaged.passUnretained(event).toOpaque()
        let modifiedPtr = Unmanaged.passUnretained(modifiedEvent).toOpaque()

        if originalPtr == modifiedPtr {
            return Unmanaged.passUnretained(modifiedEvent)
        } else {
            return Unmanaged.passRetained(modifiedEvent)
        }
    }

    return nil
}
