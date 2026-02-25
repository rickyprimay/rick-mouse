//
//  AccessibilityPermissionManager.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import Cocoa
import Combine

@MainActor
final class AccessibilityPermissionManager: ObservableObject {

    @Published private(set) var isGranted: Bool = false
    @Published private(set) var isChecking: Bool = false

    private var checkTimer: Timer?

    init() {
        checkPermission()
    }

    deinit {
            checkTimer?.invalidate()
    }
    
    func checkPermission() {
        isGranted = AXIsProcessTrusted()
    }

    func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        startMonitoring()
    }

    func startMonitoring() {
        guard checkTimer == nil else { return }
        isChecking = true

        checkTimer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.permissionCheckInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.checkPermission()
                if self.isGranted {
                    self.stopMonitoring()
                }
            }
        }
    }

    func stopMonitoring() {
        checkTimer?.invalidate()
        checkTimer = nil
        isChecking = false
    }
}
