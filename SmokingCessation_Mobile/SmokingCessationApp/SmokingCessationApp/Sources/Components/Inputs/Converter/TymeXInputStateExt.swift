//
//  TymeXInputStateExt.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 07/04/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXInputState {
    func getTitleColor(isInputSelected: Bool, isFirstResponder: Bool, isAmountEmpty: Bool) -> UIColor {
        switch self {
        case .focus:
            return SmokingCessation.colorTextLink
        case .loseFocus:
            return SmokingCessation.colorTextSubtle
        case .error:
            let shouldShowRedColor = (isInputSelected && (isFirstResponder || isAmountEmpty))
            return shouldShowRedColor ? SmokingCessation.colorTextError : SmokingCessation.colorTextSubtle
        case .filledError:
            return SmokingCessation.colorTextSubtle
        }
    }

    func getAmountColor(isInputSelected: Bool) -> UIColor {
        switch self {
        case .focus:
            SmokingCessation.colorTextLink
        case .loseFocus:
            SmokingCessation.colorTextDefault
        case .error, .filledError:
            (isInputSelected) ? SmokingCessation.colorTextError : SmokingCessation.colorTextDefault
        }
    }

    var borderColor: UIColor {
        switch self {
        case .focus, .loseFocus:
            SmokingCessation.colorStrokeInfoStrong
        case .error, .filledError:
            SmokingCessation.colorStrokeErrorBase
        }
    }
}
