//
//  MouseEventInterceptor.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import CoreGraphics
import Combine

final class MouseEventInterceptor: ObservableObject {

    private let eventTapManager = EventTapManager()
    private let gestureEngine: GestureEngine
    private let scrollEngine: ScrollEngine
    private let shortcutExecutor: ShortcutExecutor

    @MainActor @Published private(set) var isActive: Bool = false
    @MainActor @Published var configuration: UserConfiguration {
        didSet {
            _threadSafeConfiguration = configuration
        }
    }

    private nonisolated(unsafe) var _threadSafeConfiguration: UserConfiguration

    private nonisolated(unsafe) var lastOtherMouseDownTime: TimeInterval = 0
    private nonisolated(unsafe) var lastOtherMouseDownButton: Int64 = -1
    private nonisolated(unsafe) var otherMouseClickCount: Int = 0
    private nonisolated(unsafe) var isHolding: Bool = false
    private nonisolated(unsafe) var isDragging: Bool = false
    private nonisolated(unsafe) var accumulatedDragX: Int64 = 0
    private nonisolated(unsafe) var accumulatedDragY: Int64 = 0
    private nonisolated(unsafe) var holdTimer: DispatchWorkItem?

    @MainActor
    init(
        configuration: UserConfiguration,
        gestureEngine: GestureEngine,
        scrollEngine: ScrollEngine,
        shortcutExecutor: ShortcutExecutor
    ) {
        self._configuration = Published(initialValue: configuration)
        self._threadSafeConfiguration = configuration
        self.gestureEngine = gestureEngine
        self.scrollEngine = scrollEngine
        self.shortcutExecutor = shortcutExecutor
    }

    @MainActor
    func start() {
        guard configuration.isEnabled else { return }

        eventTapManager.start { [weak self] type, event in
            guard let self else { return Unmanaged.passUnretained(event) }
            return self.processEvent(type: type, event: event)
        }
        isActive = eventTapManager.isRunning
    }

    @MainActor
    func stop() {
        eventTapManager.stop()
        isActive = false
    }

    @MainActor
    func restart() {
        stop()
        start()
    }

    // MARK: - Event Processing

    private nonisolated func processEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        switch type {
        case .otherMouseDown:
            return handleOtherMouseDown(event: event)

        case .otherMouseUp:
            return handleOtherMouseUp(event: event)

        case .otherMouseDragged:
            return handleOtherMouseDragged(event: event)

        case .scrollWheel:
            return handleScrollWheel(event: event)

        default:
            return Unmanaged.passUnretained(event)
        }
    }

    // MARK: - Other Mouse Down

    private nonisolated func handleOtherMouseDown(event: CGEvent) -> Unmanaged<CGEvent>? {
        let buttonNumber = event.mouseButtonNumber
        let now = ProcessInfo.processInfo.systemUptime

        print("[Interceptor] otherMouseDown button=\(buttonNumber)")

        if buttonNumber == lastOtherMouseDownButton,
           (now - lastOtherMouseDownTime) < AppConstants.doubleClickInterval {
            otherMouseClickCount += 1
        } else {
            otherMouseClickCount = 1
        }

        lastOtherMouseDownTime = now
        lastOtherMouseDownButton = buttonNumber
        isDragging = false
        isHolding = false
        accumulatedDragX = 0
        accumulatedDragY = 0

        // Check gesture trigger
        let gestureSettings = _threadSafeConfiguration.gestureSettings
        if gestureSettings.gesturesEnabled,
           buttonNumber == Int64(gestureSettings.triggerButton.rawValue) {
            gestureEngine.beginTracking()
            print("[Interceptor] gesture tracking started")
            return nil // swallow
        }

        // Hold detection
        let holdItem = DispatchWorkItem { [weak self] in
            self?.isHolding = true
        }
        holdTimer?.cancel()
        holdTimer = holdItem
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.holdDetectionDelay, execute: holdItem)

        // If this button has any mapping, swallow the Down event
        if let button = MouseButton(rawValue: Int(buttonNumber)),
           hasAnyMapping(for: button) {
            print("[Interceptor] swallowed down for mapped button \(button)")
            return nil
        }

        return Unmanaged.passUnretained(event)
    }

    // MARK: - Other Mouse Up

    private nonisolated func handleOtherMouseUp(event: CGEvent) -> Unmanaged<CGEvent>? {
        let buttonNumber = event.mouseButtonNumber

        print("[Interceptor] otherMouseUp button=\(buttonNumber) isDragging=\(isDragging) isHolding=\(isHolding) clickCount=\(otherMouseClickCount)")

        holdTimer?.cancel()
        holdTimer = nil

        // Check gesture trigger
        let gestureSettings = _threadSafeConfiguration.gestureSettings
        if gestureSettings.gesturesEnabled,
           buttonNumber == Int64(gestureSettings.triggerButton.rawValue) {
            let gesture = gestureEngine.endTracking()
            print("[Interceptor] gesture ended: \(String(describing: gesture))")
            if let gesture {
                let executor = shortcutExecutor
                let settings = _threadSafeConfiguration.gestureSettings
                let action: MouseAction
                switch gesture {
                case .up: action = settings.dragUpAction
                case .down: action = settings.dragDownAction
                case .left: action = settings.dragLeftAction
                case .right: action = settings.dragRightAction
                case .none: action = .none
                }
                if action != .none {
                    print("[Interceptor] executing gesture action: \(action)")
                    DispatchQueue.global(qos: .userInteractive).async {
                        executor.execute(action: action)
                    }
                }
                isHolding = false
                isDragging = false
                return nil
            }
            // No gesture detected — fall through to button mapping
        }

        // Button mapping
        if let button = MouseButton(rawValue: Int(buttonNumber)) {
            var clickType: ClickType = .singleClick

            if isDragging {
                clickType = .clickAndDrag
            } else if isHolding {
                clickType = .clickAndHold
            } else if otherMouseClickCount >= 2 {
                clickType = .doubleClick
            }

            print("[Interceptor] evaluating mapping button=\(button) clickType=\(clickType)")

            if let mapping = findMapping(button: button, clickType: clickType), mapping.action != .none {
                let actionToExecute = mapping.action
                let executor = shortcutExecutor
                print("[Interceptor] EXECUTING action: \(actionToExecute)")
                DispatchQueue.global(qos: .userInteractive).async {
                    executor.execute(action: actionToExecute)
                }
                isHolding = false
                isDragging = false
                return nil
            }

            // Double click fallback to single click mapping
            if clickType == .doubleClick,
               let singleMapping = findMapping(button: button, clickType: .singleClick),
               singleMapping.action != .none {
                let actionToExecute = singleMapping.action
                let executor = shortcutExecutor
                print("[Interceptor] EXECUTING fallback single-click action: \(actionToExecute)")
                DispatchQueue.global(qos: .userInteractive).async {
                    executor.execute(action: actionToExecute)
                }
                isHolding = false
                isDragging = false
                return nil
            }

            // We swallowed the down event, so swallow the up too
            if hasAnyMapping(for: button) {
                isHolding = false
                isDragging = false
                return nil
            }
        }

        isHolding = false
        isDragging = false
        return Unmanaged.passUnretained(event)
    }

    // MARK: - Other Mouse Dragged

    private nonisolated func handleOtherMouseDragged(event: CGEvent) -> Unmanaged<CGEvent>? {
        let buttonNumber = event.mouseButtonNumber

        let gestureSettings = _threadSafeConfiguration.gestureSettings
        if gestureSettings.gesturesEnabled,
           buttonNumber == Int64(gestureSettings.triggerButton.rawValue) {
            // Only feed gesture engine, do NOT set isDragging
            gestureEngine.trackMovement(deltaX: Double(event.mouseDeltaX), deltaY: Double(event.mouseDeltaY))
            return nil
        }

        // Only accumulate drag for non-gesture buttons
        accumulatedDragX += event.mouseDeltaX
        accumulatedDragY += event.mouseDeltaY

        let dragThreshold: Int64 = 5
        if abs(accumulatedDragX) > dragThreshold || abs(accumulatedDragY) > dragThreshold {
            isDragging = true
        }

        return Unmanaged.passUnretained(event)
    }

    // MARK: - Scroll Wheel

    private nonisolated func handleScrollWheel(event: CGEvent) -> Unmanaged<CGEvent>? {
        let gestureSettings = _threadSafeConfiguration.gestureSettings
        if gestureSettings.gesturesEnabled, gestureEngine.isTracking {
            let deltaY = event.scrollDeltaY
            let executor = shortcutExecutor
            if deltaY < 0 {
                let action = gestureSettings.scrollUpAction
                if action != .none {
                    DispatchQueue.global(qos: .userInteractive).async {
                        executor.execute(action: action)
                    }
                }
            } else if deltaY > 0 {
                let action = gestureSettings.scrollDownAction
                if action != .none {
                    DispatchQueue.global(qos: .userInteractive).async {
                        executor.execute(action: action)
                    }
                }
            }
            return nil
        }

        // For scroll processing, modify the event in-place instead of creating new events
        let scrollSettings = _threadSafeConfiguration.scrollSettings
        scrollEngine.applyScrollSettings(event: event, settings: scrollSettings)
        return Unmanaged.passUnretained(event)
    }

    // MARK: - Helpers

    private nonisolated func findMapping(button: MouseButton, clickType: ClickType) -> ButtonMapping? {
        let mappings = _threadSafeConfiguration.buttonMappings
        print("[Interceptor] searching \(mappings.count) mappings for button=\(button) clickType=\(clickType)")
        for m in mappings {
            print("[Interceptor]   mapping: button=\(m.button) clickType=\(m.clickType) action=\(m.action)")
        }
        return mappings.first { $0.button == button && $0.clickType == clickType }
    }

    private nonisolated func hasAnyMapping(for button: MouseButton) -> Bool {
        _threadSafeConfiguration.buttonMappings.contains { $0.button == button && $0.action != .none }
    }
}
