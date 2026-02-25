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
            guard let self else { return event }
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

    private nonisolated func processEvent(type: CGEventType, event: CGEvent) -> CGEvent? {
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
            return event
        }
    }

    private nonisolated func handleOtherMouseDown(event: CGEvent) -> CGEvent? {
        let buttonNumber = event.mouseButtonNumber
        let now = ProcessInfo.processInfo.systemUptime

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

        let gestureSettings = _threadSafeConfiguration.gestureSettings
        if gestureSettings.gesturesEnabled,
           buttonNumber == Int64(gestureSettings.triggerButton.rawValue) {
            gestureEngine.beginTracking()
            return nil
        }

        let holdItem = DispatchWorkItem { [weak self] in
            self?.isHolding = true
        }
        holdTimer?.cancel()
        holdTimer = holdItem
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.holdDetectionDelay, execute: holdItem)

        if let button = MouseButton(rawValue: Int(buttonNumber)) {
            if hasAnyMapping(for: button) {
                return nil
            }
        }

        return event
    }

    private nonisolated func handleOtherMouseUp(event: CGEvent) -> CGEvent? {
        let buttonNumber = event.mouseButtonNumber

        holdTimer?.cancel()
        holdTimer = nil

        let gestureSettings = _threadSafeConfiguration.gestureSettings
        if gestureSettings.gesturesEnabled,
           buttonNumber == Int64(gestureSettings.triggerButton.rawValue) {
            let gesture = gestureEngine.endTracking()
            if let gesture {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.executeGestureAction(gesture: gesture)
                }
                return nil
            }
        }

        if let button = MouseButton(rawValue: Int(buttonNumber)) {
            var clickType: ClickType = .singleClick
            
            if isDragging {
                clickType = .clickAndDrag
            } else if isHolding {
                clickType = .clickAndHold
            } else if otherMouseClickCount >= 2 {
                clickType = .doubleClick
            }

            if let mapping = findMapping(button: button, clickType: clickType), mapping.action != .none {
                let actionToExecute = mapping.action
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.shortcutExecutor.execute(action: actionToExecute)
                }
                isHolding = false
                isDragging = false
                return nil
            } else if clickType == .doubleClick, let singleMapping = findMapping(button: button, clickType: .singleClick), singleMapping.action != .none {
                let actionToExecute = singleMapping.action
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.shortcutExecutor.execute(action: actionToExecute)
                }
                isHolding = false
                isDragging = false
                return nil
            }
            if hasAnyMapping(for: button) {
                isHolding = false
                isDragging = false
                return nil
            }
        }

        isHolding = false
        isDragging = false
        return event
    }

    private nonisolated func handleOtherMouseDragged(event: CGEvent) -> CGEvent? {
        let buttonNumber = event.mouseButtonNumber
        isDragging = true

        let gestureSettings = _threadSafeConfiguration.gestureSettings
        if gestureSettings.gesturesEnabled,
           buttonNumber == Int64(gestureSettings.triggerButton.rawValue) {
            let deltaX = event.mouseDeltaX
            let deltaY = event.mouseDeltaY
            gestureEngine.trackMovement(deltaX: Double(deltaX), deltaY: Double(deltaY))
            return nil
        }

        return event
    }

    private nonisolated func handleScrollWheel(event: CGEvent) -> CGEvent? {
        let gestureSettings = _threadSafeConfiguration.gestureSettings
        if gestureSettings.gesturesEnabled, gestureEngine.isTracking {
            let deltaY = event.scrollDeltaY
            if deltaY < 0 {
                let action = gestureSettings.scrollUpAction
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.executeDirectionAction(action: action)
                }
            } else if deltaY > 0 {
                let action = gestureSettings.scrollDownAction
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.executeDirectionAction(action: action)
                }
            }
            return nil
        }

        return scrollEngine.processScrollEvent(event: event, settings: _threadSafeConfiguration.scrollSettings)
    }

    private nonisolated func findMapping(button: MouseButton, clickType: ClickType) -> ButtonMapping? {
        _threadSafeConfiguration.buttonMappings.first { $0.button == button && $0.clickType == clickType }
    }

    private nonisolated func hasAnyMapping(for button: MouseButton) -> Bool {
        _threadSafeConfiguration.buttonMappings.contains { $0.button == button && $0.action != .none }
    }

    private nonisolated func executeGestureAction(gesture: GestureDirection) {
        let settings = _threadSafeConfiguration.gestureSettings
        let action: MouseAction

        switch gesture {
        case .up: action = settings.dragUpAction
        case .down: action = settings.dragDownAction
        case .left: action = settings.dragLeftAction
        case .right: action = settings.dragRightAction
        case .none: return
        }

        shortcutExecutor.execute(action: action)
    }

    private nonisolated func executeDirectionAction(action: MouseAction) {
        shortcutExecutor.execute(action: action)
    }
}
