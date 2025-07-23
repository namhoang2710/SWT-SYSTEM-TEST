//
//  TymeXInputConverterType.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 07/04/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public enum TymeXInputConverterType {
    case currency(UIImage?, String)
    case points

    var title: String {
        switch self {
        case .currency(_, let currencyName):
            return currencyName
        case .points:
            return "points"
        }
    }

    var flagIcon: UIImage? {
        switch self {
        case .currency(let currencyFlag, _):
            return currencyFlag
        case .points:
            return nil
        }
    }
}
