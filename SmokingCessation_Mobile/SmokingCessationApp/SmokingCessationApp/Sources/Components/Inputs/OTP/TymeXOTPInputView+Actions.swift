//
//  TymeXOTPInputView+Actions.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 30/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public extension TymeXOTPInputView {
    func handleAddAction(newText: String) {
        // Reset & Hide error state when add an OTP code
        resetAndHideErrorState()

        currentTextField?.setText(newText: newText)
        if let nextField = getNextOTPTextField() {
            moveBottomLine(to: nextField)
        } else {
            // For Last OTP code
            completionHandler?(getOTP())
        }
        currentTextField = getNextOTPTextField() ?? getTextFields().last
    }

    func handleDeleteAction() {
        // Reset & Hide error state when delete an OTP code
        resetAndHideErrorState()

        if isLastOTP() {
            if !isTextEmpty() {
                // Clear text for current textfield
                currentTextField?.setText(newText: "")
                currentTextField = getTextFields().last
            } else {
                // move to previous textfield then clear text
                if let previousField = getPreviousOTPTextField() {
                    moveBottomLine(to: previousField)
                    previousField.setText(newText: "")
                    currentTextField = previousField
                }
            }
        } else {
            // move to previous textfield then clear text
            if let previousField = getPreviousOTPTextField() {
                moveBottomLine(to: previousField)
                previousField.setText(newText: "")
                currentTextField = previousField
            } else {
                currentTextField?.setText(newText: "")
            }
        }
    }
}
