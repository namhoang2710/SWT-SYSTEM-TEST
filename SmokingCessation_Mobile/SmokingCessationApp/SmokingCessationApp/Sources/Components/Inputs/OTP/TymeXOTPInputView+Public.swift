//
//  TymeXOTPInputView+Public.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 12/09/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation

public protocol TymeXOTPInputViewProtocol: AnyObject {
    // variables
    var completionHandler: ((String) -> Void)? { get set }

    // functions
    func focusOnLastTextField()
    func getHiddenTextfield() -> TymeXHiddenTextField
    func getNumberOfOTPFields() -> Int
    func autoFillOTP(_ otp: String)
    func updateErrorMessage(errorMessage: String)
    func showErrorState()
    func resetStates()
}

extension TymeXOTPInputView: TymeXOTPInputViewProtocol {
    public func focusOnLastTextField() {
        hiddenTextField.becomeFirstResponder()
    }

    public func getHiddenTextfield() -> TymeXHiddenTextField {
        return hiddenTextField
    }

    public func showErrorState() {
        errorStackView.isHidden = false
        updateBottomLineBackground(color: SmokingCessation.colorStrokeErrorBase)
        playAnimationFocusState(strokeColor: SmokingCessation.colorStrokeErrorBase)
        for textField in getTextFields() {
            if textField == currentTextField {
                textField.currentState = .errorFocus
            } else {
                textField.currentState = .errorLostFocus
            }
            // Shake textfields for error case
            textField.mxShake()
        }

        bottomLine.mxShake()

        // Play hapticks
        TymeXHapticFeedback.error.vibrate()
    }

    public func updateErrorMessage(errorMessage: String) {
        errorMessageLabel.attributedText = NSAttributedString(
            string: errorMessage,
            attributes: SmokingCessation.textLabelDefaultS.color(SmokingCessation.colorTextError)
        )
    }

    public func getNumberOfOTPFields() -> Int {
        return numberOfFields
    }

    public func autoFillOTP(_ otp: String) {
        let otpArray = Array(otp)
        let textFields = self.getTextFields()
        if otpArray.count != textFields.count {
            return
        }

        let totalDelay: TimeInterval = AnimationDuration.duration4.value
        let fieldDuration = totalDelay / Double(otpArray.count)

        for (index, otpTextField) in textFields.enumerated() {
            // Calculate delay time for each textfield
            DispatchQueue.main.asyncAfter(deadline: .now() + fieldDuration * Double(index)) {
                let otpCode = String(otpArray[index])
                DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDuration.duration2.value) {
                    otpTextField.label.attributedText = NSAttributedString(
                        string: otpCode,
                        attributes: SmokingCessation.textLabelEmphasizeL.alignment(.center)
                    )
                }
                // Move bottom lineView
                self.moveBottomLine(to: otpTextField)
            }
        }
        // update currentTextField into last one
        currentTextField = getTextFields().last

        // Call completion handler if OTP was full filled
        if otp.count == self.numberOfFields {
            self.completionHandler?(otp)
        }
    }

    public func resetStates() {
        setupTextFieldsWithAnimation()
        if let firstTextField = getTextFields().first {
            moveBottomLine(to: firstTextField)
        }
        resetAndHideErrorState()
    }
}
