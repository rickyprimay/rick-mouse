//
//  LaunchAtLoginService.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import ServiceManagement
import Combine

@MainActor
final class LaunchAtLoginService: ObservableObject {

    @Published var isEnabled: Bool = false {
        didSet {
            guard oldValue != isEnabled else { return }
            updateLoginItem()
        }
    }

    init() {
        refreshStatus()
    }

    func refreshStatus() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    private func updateLoginItem() {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("[LaunchAtLoginService] Failed to update login item: \(error.localizedDescription)")
            refreshStatus()
        }
    }
}
