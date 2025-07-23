//
//  TymeXItemKeyboard.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 31/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public enum TymeXKeyType: Equatable {
    case number(String)
    case delete
    case touchID
    case faceID
    case none

    func getText() -> String {
        if case .number(let text) = self {
            return text
        }
        return ""
    }

    func getAccessibilityIdentifier() -> String {
        switch self {
        case .number(let value):
            return "number_\(value)"
        case .delete:
            return "delete"
        case .touchID:
            return "touchID"
        case .faceID:
            return "faceID"
        case .none:
            return "none"
        }
    }
}

public enum TymeXKeypadBiometricMode {
    case touchID
    case faceID
    case none
}

public enum TymeXKeypadBackspaceMode {
    case back
    case none
}

public enum TymeXNumericKeyboardMode {
    case fourDigits
    case sixDigits
    public var maxNumberKeyboard: Int {
        switch self {
        case .fourDigits:
            return 4
        case .sixDigits:
            return 6
        }
    }
}
