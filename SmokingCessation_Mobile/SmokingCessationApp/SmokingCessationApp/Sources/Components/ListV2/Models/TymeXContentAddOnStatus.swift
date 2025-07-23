//
//  TymeXListItemStatus.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 05/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.

// swiftlint:disable empty_enum_arguments

import Foundation
import UIKit

public enum TymeXContentAddOnStatus {
    case neutral(String)
    case green(String)
    case yellow(String)
    case red(String)
    case custom(String, UIColor)

    var content: String {
        switch self {
        case .neutral(let content):
            return content
        case .green(let content):
            return content
        case .yellow(let content):
            return content
        case .red(let content):
            return content
        case .custom(let content, _):
            return content
        }
    }

    func getColor() -> UIColor {
        switch self {
        case .neutral(_):
            return SmokingCessation.colorTextSubtle
        case .green(_):
            return SmokingCessation.colorTextSuccess
        case .yellow(_):
            return SmokingCessation.colorTextWarning
        case .red(_):
            return SmokingCessation.colorTextError
        case .custom(_, let color):
            return color
        }
    }
}
// swiftlint:enable empty_enum_arguments
