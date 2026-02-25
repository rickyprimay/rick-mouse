//
//  MouseButton.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation

enum MouseButton: Int, Codable, CaseIterable, Identifiable {
    case left = 0
    case right = 1
    case middle = 2
    case button4 = 3
    case button5 = 4

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .left: return "Left Button"
        case .right: return "Right Button"
        case .middle: return "Middle Button"
        case .button4: return "Button 4"
        case .button5: return "Button 5"
        }
    }

    var sfSymbol: String {
        switch self {
        case .left: return "computermouse.fill"
        case .right: return "computermouse.fill"
        case .middle: return "computermouse.fill"
        case .button4: return "minus.circle.fill"
        case .button5: return "plus.circle.fill"
        }
    }
}

enum ClickType: String, Codable, CaseIterable, Identifiable {
    case singleClick = "single_click"
    case doubleClick = "double_click"
    case clickAndHold = "click_and_hold"
    case clickAndDrag = "click_and_drag"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .singleClick: return "Single Click"
        case .doubleClick: return "Double Click"
        case .clickAndHold: return "Click & Hold"
        case .clickAndDrag: return "Click & Drag"
        }
    }

    var sfSymbol: String {
        switch self {
        case .singleClick: return "cursorarrow.click"
        case .doubleClick: return "cursorarrow.click.2"
        case .clickAndHold: return "hand.tap.fill"
        case .clickAndDrag: return "rectangle.and.hand.point.up.left.filled"
        }
    }
}
