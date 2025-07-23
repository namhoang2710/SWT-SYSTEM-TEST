//
//  TymeXInputConverterView+Public.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 31/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXInputConverterView {
    public var fromValue: Double {
        get { fromInputAmount.value }
        set { fromInputAmount.value = newValue }
    }

    public var toValue: Double {
        get { toInputAmount.value }
        set { toInputAmount.value = newValue }
    }

    public func updateExchangeRate(_ exchangeRateText: String) {
        exchangeRateView.updateExchangeRateText(exchangeRateText)
    }

    public func displayErrorMessage(
        with message: String, title: String? = nil,
        isShowingToTextField: Bool = true) {
        if isShowingToTextField {
            fromInputAmount.displayErrorMessage(
                with: message,
                isInputSelected: false
            )
            toInputAmount.displayErrorMessage(
                with: message, title: title,
                isInputSelected: true
            )
        } else {
            let isFromTextField = fromInputAmount == inputAmountSelected
            fromInputAmount.displayErrorMessage(
                with: message, title: isFromTextField ? title : nil,
                isInputSelected: fromInputAmount == inputAmountSelected
            )
            toInputAmount.displayErrorMessage(
                with: message, title: !isFromTextField ? title : nil,
                isInputSelected: toInputAmount == inputAmountSelected
            )
        }
        exchangeRateView.updateUI(isError: true)
    }

    public func resetErrorState(isFromField: Bool) {
        if isFromField {
            fromInputAmount.setInputState(with: TymeXInputState.focus)
            toInputAmount.setInputState(with: TymeXInputState.loseFocus)
        } else {
            fromInputAmount.setInputState(with: TymeXInputState.loseFocus)
            toInputAmount.setInputState(with: TymeXInputState.focus)
        }
        exchangeRateView.updateUI(isError: false)
    }

    public func displayHelperMessage(_ message: String, isFromField: Bool) {
        if isFromField {
            fromInputAmount.displayHelperMessage(message)
        } else {
            toInputAmount.displayHelperMessage(message)
        }
    }

    public func showDropDownIcon(flag: Bool, isFromField: Bool) {
        if isFromField {
            fromInputAmount.showDropDownIcon(flag: flag)
        } else {
            toInputAmount.showDropDownIcon(flag: flag)
        }
    }

    public func showFlagIcon(flag: Bool, isFromField: Bool) {
        if isFromField {
            fromInputAmount.showFlagIcon(flag: flag)
        } else {
            toInputAmount.showFlagIcon(flag: flag)
        }
    }

    public func showFooterInforIcon(flag: Bool) {
        let titleText = configuration.footerTitle
        let descriptionText = configuration.footerValue
        let icon = flag ? configuration.footerIcon : nil
        toInputAmount.updateFooterTitle(
            titleText, icon: icon,
            additionalText: descriptionText
        )
    }

    public func isErrorState() -> Bool {
        return fromInputAmount.isErrorState() || toInputAmount.isErrorState()
    }

    public func getExchangeRateLabel() -> UILabel {
        return exchangeRateView.getExchangeRateLabel()
    }

    public func becomeFirstActivate() {
        fromInputAmount.inputAmountTextField.becomeFirstResponder()
    }
}
