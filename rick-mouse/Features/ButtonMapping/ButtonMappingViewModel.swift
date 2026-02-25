//
//  ButtonMappingViewModel.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation
import Combine

@MainActor
final class ButtonMappingViewModel: ObservableObject {

    @Published var selectedButton: MouseButton = .button4
    @Published var selectedClickType: ClickType = .singleClick
    @Published var mappings: [ButtonMapping] = []

    var currentMapping: ButtonMapping? {
        mappings.first { $0.button == selectedButton && $0.clickType == selectedClickType }
    }

    var currentAction: MouseAction {
        currentMapping?.action ?? .none
    }

    func loadMappings(from configuration: UserConfiguration) {
        mappings = configuration.buttonMappings
    }

    func updateAction(_ action: MouseAction, appState: AppState) {
        if let index = mappings.firstIndex(where: {
            $0.button == selectedButton && $0.clickType == selectedClickType
        }) {
            mappings[index].action = action
        } else {
            let newMapping = ButtonMapping(
                button: selectedButton,
                clickType: selectedClickType,
                action: action
            )
            mappings.append(newMapping)
        }
        appState.configuration.buttonMappings = mappings
        appState.saveConfiguration()
    }

    var remappableButtons: [MouseButton] {
        [.middle, .button4, .button5]
    }
}
