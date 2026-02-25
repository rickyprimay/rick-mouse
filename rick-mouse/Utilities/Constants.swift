//
//  Constants.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation

enum AppConstants {

    static let appName = "Rick Mouse"
    static let appVersion = "1.0.0"
    static let bundleIdentifier = "com.rickyprimay.rick-mouse"

    static let configFileName = "rick-mouse-config.json"
    static let appSupportDirectoryName = "RickMouse"

    static let defaultDragThreshold: Double = 30.0
    static let minimumDragThreshold: Double = 10.0
    static let maximumDragThreshold: Double = 100.0

    static let scrollDecelerationRate: Double = 0.92
    static let scrollMinimumVelocity: Double = 0.1
    static let scrollBounceCoefficient: Double = 0.3
    static let scrollPrecisionMultiplier: Double = 0.3
    static let scrollDefaultSpeed: Double = 1.0

    static let eventTapRecoveryInterval: TimeInterval = 2.0
    static let doubleClickInterval: TimeInterval = 0.3
    static let holdDetectionDelay: TimeInterval = 0.4

    static let permissionCheckInterval: TimeInterval = 1.0

    static let windowWidth: CGFloat = 680
    static let windowHeight: CGFloat = 520
    static let sidebarWidth: CGFloat = 200
    static let cornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 16
    static let animationDuration: Double = 0.25
}
