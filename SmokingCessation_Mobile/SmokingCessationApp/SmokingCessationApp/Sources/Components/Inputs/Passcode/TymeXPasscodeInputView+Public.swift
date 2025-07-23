//
//  TymeXPasscodeField+Public.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 30/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public protocol TymeXPasscodeInputViewProtocol: AnyObject {
    // variables
    var completionHandler: ((String) -> Void)? { get set }
    var numericKeypad: TymeXNumericKeyPad? { get set }

    // functions
    func getNumberOfPasscodeFields() -> Int
    func getSelectedPasscode() -> String
    func resetState()
    func updateErrorMessage(errorMessage: String)
    func showErrorState()
    func updateHelperMessage(message: String)
    func showHelperText(flag: Bool)
    func getHelperTextLabel() -> UILabel
    func getErrorMessageLabel() -> UILabel
}

extension TymeXPasscodeInputView: TymeXPasscodeInputViewProtocol {
    public func getNumberOfPasscodeFields() -> Int {
        return numberOfFields
    }

    public func getSelectedPasscode() -> String {
        return selectedPasscodes.joined(separator: "")
    }

    public func resetState() {
        // reset to defaut state
        for passcodeField in getPasscodeFields() {
            passcodeField.isFilled = false
            passcodeField.currentState = .defaultState
        }
    }

    public func updateErrorMessage(errorMessage: String) {
        errorMessageLabel.attributedText = NSAttributedString(
            string: errorMessage,
            attributes: SmokingCessation.textLabelDefaultS.color(SmokingCessation.colorTextError)
        )
    }
    public func showErrorState() {
        guard !isShowingError else { return }
        isShowingError = true
        showHelperText(flag: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.showErrorStatesUI()
            TymeXHapticFeedback.error.vibrate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                self.resetErrorStateToDefault(isHiddenErrorMessage: false)
                self.isShowingError = false
                self.resetPasscodeList()
            }
        }
    }

    public func updateHelperMessage(message: String) {
        helperTextLabel.attributedText = NSAttributedString(
            string: message,
            attributes: SmokingCessation.textLabelDefaultS.color(SmokingCessation.colorTextSubtle).alignment(.center)
        )
    }

    public func showHelperText(flag: Bool) {
        helperTextLabel.isHidden = !flag
    }

    public func getHelperTextLabel() -> UILabel {
        return helperTextLabel
    }

    public func getErrorMessageLabel() -> UILabel {
        return errorMessageLabel
    }
}
