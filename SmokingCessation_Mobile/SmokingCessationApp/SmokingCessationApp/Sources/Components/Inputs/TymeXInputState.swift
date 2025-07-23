//
//  TymeXInputState.swift
//  ios-ui-components
//
//  Created by Duy Le on 09/06/2021.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

protocol TymeXInputStateAttributes {
    var colorInputField: UIColor { get }
    var inputTextFieldTintColor: UIColor { get }
    var currencySymbolColor: UIColor { get }
    func getColorTitleLabel(isTyping: Bool) -> UIColor
    func getPlaceHolderColor(isTyping: Bool) -> UIColor
    func isInputEmpty(input: String?) -> Bool
}

public enum TymeXInputState {
    case focus
    case loseFocus
    case error
    case filledError
}

extension TymeXInputState: TymeXInputStateAttributes {
    var colorInputField: UIColor {
        switch self {
        case .loseFocus:
            return SmokingCessation.colorTextDefault
        case .focus:
            return SmokingCessation.colorTextLink
        case .error:
            return SmokingCessation.colorTextError
        case .filledError:
            return SmokingCessation.colorTextError
        }
    }

    func getPlaceHolderColor(isTyping: Bool = false) -> UIColor {
        switch self {
        case .loseFocus:
            return SmokingCessation.colorTextSubtle
        case .focus:
            return SmokingCessation.colorTextSubtle
        case .error:
            return isTyping ? SmokingCessation.colorTextSubtle : SmokingCessation.colorTextError
        case .filledError:
            return SmokingCessation.colorTextSubtle
        }
    }

    var currencySymbolColor: UIColor {
        switch self {
        case .loseFocus:
            return SmokingCessation.colorTextSubtle
        case .focus:
            return SmokingCessation.colorTextLink
        case .error:
            return SmokingCessation.colorTextError
        case .filledError:
            return SmokingCessation.colorTextError
        }
    }

    func getPlaceHolderTypography(
        isEmptyText: Bool, isFocus: Bool, alignment: NSTextAlignment = .center
    ) -> [NSAttributedString.Key: Any] {
        switch (self, isEmptyText, isFocus) {
        case (.loseFocus, true, _):
            return SmokingCessation.textLabelDefaultL.color(SmokingCessation.colorTextSubtle).alignment(alignment)
        case (.loseFocus, false, _):
            return SmokingCessation.textLabelDefaultXs.color(SmokingCessation.colorTextSubtle).alignment(alignment)
        case (.focus, true, _), (.focus, false, _):
            return SmokingCessation.textLabelDefaultXs.color(SmokingCessation.colorTextLink).alignment(alignment)
        case (.error, true, true):
            return SmokingCessation.textLabelDefaultXs.color(SmokingCessation.colorTextError).alignment(alignment)
        case (.error, true, false):
            return SmokingCessation.textLabelDefaultL.color(SmokingCessation.colorTextError).alignment(alignment)
        case (.error, false, true):
            return SmokingCessation.textLabelDefaultXs.color(SmokingCessation.colorTextError).alignment(alignment)
        case (.error, false, false):
            return SmokingCessation.textLabelDefaultXs.color(SmokingCessation.colorTextSubtle).alignment(alignment)
        case (.filledError, true, _):
            return SmokingCessation.textLabelDefaultXs.color(SmokingCessation.colorTextError).alignment(alignment)
        case (.filledError, false, _):
            return SmokingCessation.textLabelDefaultXs.color(SmokingCessation.colorTextSubtle).alignment(alignment)
        }
    }

    var inputTextFieldTintColor: UIColor {
        switch self {
        case .loseFocus, .focus:
            return SmokingCessation.colorBackgroundSelectBase
        case .error, .filledError:
            return SmokingCessation.colorBackgroundErrorBase
        }
    }

    func getColorTitleLabel(isTyping: Bool) -> UIColor {
        switch self {
        case .loseFocus:
            return SmokingCessation.colorTextSubtle
        case .focus:
            return SmokingCessation.colorTextLink
        case .error, .filledError:
            return isTyping ? SmokingCessation.colorTextError : SmokingCessation.colorTextSubtle
        }
    }

    func isInputEmpty(input: String?) -> Bool {
        guard let input = input, !input.isEmpty else { return true }
        return false
    }
}
