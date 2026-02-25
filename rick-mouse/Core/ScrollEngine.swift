//
//  ScrollEngine.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import CoreGraphics
import QuartzCore
import AppKit

final class ScrollEngine {

    private var velocityY: Double = 0
    private var velocityX: Double = 0
    private var displayLink: CADisplayLink?
    private var isAnimating: Bool = false
    private var lastTimestamp: TimeInterval = 0

    private var currentSmoothness: ScrollSmoothness = .regular
        private var currentInertia: Double = 0.7
    private var currentSpeed: Double = 1.0
    private var invertDirection: Bool = false
    private var precisionScrollEnabled: Bool = true

    init() {
        // CADisplayLink will be created on demand when animation starts
    }

    deinit {
        stopAnimation()
    }

    private class DisplayLinkTarget: NSObject {
        weak var engine: ScrollEngine?
        init(engine: ScrollEngine) {
            self.engine = engine
            super.init()
        }
        @objc func displayLinkFired(_ link: CADisplayLink) {
            engine?.displayLinkFired()
        }
    }

    func processScrollEvent(event: CGEvent, settings: ScrollSettings) -> CGEvent? {
        updateSettings(settings)

        let deltaY = event.scrollFixedDeltaY
        let deltaX = event.scrollFixedDeltaX

        let directionMultiplier: Double = invertDirection ? -1.0 : 1.0

        let precisionMultiplier: Double = (precisionScrollEnabled && event.hasShift)
            ? AppConstants.scrollPrecisionMultiplier
            : 1.0

        let adjustedDeltaY = deltaY * directionMultiplier * precisionMultiplier * currentSpeed
        let adjustedDeltaX = deltaX * directionMultiplier * precisionMultiplier * currentSpeed

        switch currentSmoothness {
        case .off:
            return createStepScrollEvent(deltaY: adjustedDeltaY, deltaX: adjustedDeltaX)

        case .regular:
            return createSmoothScrollEvent(deltaY: adjustedDeltaY, deltaX: adjustedDeltaX)

        case .high:
            addMomentum(deltaY: adjustedDeltaY, deltaX: adjustedDeltaX)
            return createSmoothScrollEvent(deltaY: adjustedDeltaY, deltaX: adjustedDeltaX)
        }
    }

    /// Modifies the given scroll event in-place based on settings.
    /// This avoids creating new CGEvent objects which cause issues with CGEventTap.
    func applyScrollSettings(event: CGEvent, settings: ScrollSettings) {
        updateSettings(settings)

        let deltaY = event.scrollFixedDeltaY
        let deltaX = event.scrollFixedDeltaX

        let directionMultiplier: Double = invertDirection ? -1.0 : 1.0
        let precisionMultiplier: Double = (precisionScrollEnabled && event.hasShift)
            ? AppConstants.scrollPrecisionMultiplier
            : 1.0

        let adjustedDeltaY = deltaY * directionMultiplier * precisionMultiplier * currentSpeed
        let adjustedDeltaX = deltaX * directionMultiplier * precisionMultiplier * currentSpeed

        // Modify the original event in-place
        event.setIntegerValueField(.scrollWheelEventDeltaAxis1, value: Int64(adjustedDeltaY.clamped(to: -127...127)))
        event.setIntegerValueField(.scrollWheelEventDeltaAxis2, value: Int64(adjustedDeltaX.clamped(to: -127...127)))

        // Also apply momentum if high smoothness
        if currentSmoothness == .high {
            addMomentum(deltaY: adjustedDeltaY, deltaX: adjustedDeltaX)
        }
    }

    private func updateSettings(_ settings: ScrollSettings) {
        currentSmoothness = settings.smoothness
        currentInertia = settings.inertiaStrength
        currentSpeed = settings.scrollSpeed
        invertDirection = settings.invertDirection
        precisionScrollEnabled = settings.precisionScrollModifier
    }

    private func createStepScrollEvent(deltaY: Double, deltaX: Double) -> CGEvent? {
        let event = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .line,
            wheelCount: 2,
            wheel1: Int32(deltaY.clamped(to: -10...10)),
            wheel2: Int32(deltaX.clamped(to: -10...10)),
            wheel3: 0
        )
        return event
    }

    private func createSmoothScrollEvent(deltaY: Double, deltaX: Double) -> CGEvent? {
        let event = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 2,
            wheel1: Int32(deltaY * 3),
            wheel2: Int32(deltaX * 3),
            wheel3: 0
        )
        return event
    }

    private func addMomentum(deltaY: Double, deltaX: Double) {
        velocityY += deltaY * currentInertia
        velocityX += deltaX * currentInertia

        if !isAnimating {
            startAnimation()
        }
    }

    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        lastTimestamp = CACurrentMediaTime()
        let target = DisplayLinkTarget(engine: self)
        
        // Use NSScreen's display link as recommended in macOS
        if let screen = NSScreen.main {
            let link = screen.displayLink(target: target, selector: #selector(DisplayLinkTarget.displayLinkFired(_:)))
            link.add(to: .current, forMode: .common)
            displayLink = link
        }
    }

    private func stopAnimation() {
        guard isAnimating else { return }
        isAnimating = false
        displayLink?.invalidate()
        displayLink = nil
        velocityY = 0
        velocityX = 0
    }

    private func displayLinkFired() {
        let now = CACurrentMediaTime()
        let dt = now - lastTimestamp
        lastTimestamp = now

        guard dt > 0, dt < 0.1 else { return }

        velocityY *= AppConstants.scrollDecelerationRate
        velocityX *= AppConstants.scrollDecelerationRate

        if abs(velocityY) < AppConstants.scrollMinimumVelocity &&
           abs(velocityX) < AppConstants.scrollMinimumVelocity {
            stopAnimation()
            return
        }

        if let event = createSmoothScrollEvent(deltaY: velocityY, deltaX: velocityX) {
            event.post(tap: .cghidEventTap)
        }
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
