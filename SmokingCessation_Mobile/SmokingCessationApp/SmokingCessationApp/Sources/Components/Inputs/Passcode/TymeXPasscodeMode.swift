//
//  TymeXPasscodeMode.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 30/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation

public enum TymeXPasscodeMode {
    case fourDigits
    case sixDigits
    public var numberOfFields: Int {
        switch self {
        case .fourDigits:
            return 4
        case .sixDigits:
            return 6
        }
    }
}
