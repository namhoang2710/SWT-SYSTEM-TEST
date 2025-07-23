//
//  OTPMode.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 11/09/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation

public enum TymeXOTPMode {
    case fourDigits
    case sixDigits
    var numberOfFields: Int {
        switch self {
        case .fourDigits:
            return 4
        case .sixDigits:
            return 6
        }
    }
}
