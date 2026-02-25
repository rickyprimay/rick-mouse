//
//  CGEvent+Helpers.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import CoreGraphics

extension CGEvent {

    var mouseButtonNumber: Int64 {
        getIntegerValueField(.mouseEventButtonNumber)
    }

    var scrollDeltaY: Int64 {
        getIntegerValueField(.scrollWheelEventDeltaAxis1)
    }

    var scrollDeltaX: Int64 {
        getIntegerValueField(.scrollWheelEventDeltaAxis2)
    }

    var scrollFixedDeltaY: Double {
        getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1)
    }

    var scrollFixedDeltaX: Double {
        getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis2)
    }

    var mouseDeltaX: Int64 {
        getIntegerValueField(.mouseEventDeltaX)
    }
    var mouseDeltaY: Int64 {
        getIntegerValueField(.mouseEventDeltaY)
    }
    var hasCommand: Bool {
        flags.contains(.maskCommand)
    }

    var hasOption: Bool {
        flags.contains(.maskAlternate)
    }
    var hasControl: Bool {
        flags.contains(.maskControl)
    }

    var hasShift: Bool {
        flags.contains(.maskShift)
    }
}
