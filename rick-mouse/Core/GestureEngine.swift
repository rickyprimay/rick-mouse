//
//  GestureEngine.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation

enum GestureDirection {
    case up
    case down
    case left
    case right
    case none
}

final class GestureEngine {

    private(set) var isTracking: Bool = false

    private var accumulatedDeltaX: Double = 0
    private var accumulatedDeltaY: Double = 0
    private var dragThreshold: Double = AppConstants.defaultDragThreshold

    func updateThreshold(_ threshold: Double) {
        dragThreshold = threshold
    }

    func beginTracking() {
        isTracking = true
        accumulatedDeltaX = 0
        accumulatedDeltaY = 0
    }

    func trackMovement(deltaX: Double, deltaY: Double) {
        guard isTracking else { return }
        accumulatedDeltaX += deltaX
        accumulatedDeltaY += deltaY
    }

    @discardableResult
    func endTracking() -> GestureDirection? {
        guard isTracking else { return nil }
        isTracking = false

        let direction = resolveDirection()

        accumulatedDeltaX = 0
        accumulatedDeltaY = 0

        return direction
    }

    private func resolveDirection() -> GestureDirection? {
        let absX = abs(accumulatedDeltaX)
        let absY = abs(accumulatedDeltaY)

        guard max(absX, absY) >= dragThreshold else { return nil }

        if absY > absX {
            return accumulatedDeltaY < 0 ? .up : .down
        } else {
            return accumulatedDeltaX < 0 ? .left : .right
        }
    }

    var currentVector: (x: Double, y: Double) {
        let magnitude = sqrt(accumulatedDeltaX * accumulatedDeltaX + accumulatedDeltaY * accumulatedDeltaY)
        guard magnitude > 0 else { return (0, 0) }
        return (accumulatedDeltaX / magnitude, accumulatedDeltaY / magnitude)
    }
}
