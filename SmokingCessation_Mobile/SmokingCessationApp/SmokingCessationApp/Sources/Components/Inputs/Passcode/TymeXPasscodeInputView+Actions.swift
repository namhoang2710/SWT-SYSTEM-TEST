//
//  TymeXPasscodeInputView+Actions.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 30/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public extension TymeXPasscodeInputView {
    func handleAddAction(currentPasscode: String, fullPasscode: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // force to hide error message when adding a new passcode
            hideErrorMessage(flag: true)
            showHelperText(flag: true)

            if isFilledAllPasscode() {
                self.updateListPasscode(newPasscode: currentPasscode)
                // In case inputted all Passcode correctly before then inputted a new
                // Passcode -> need reset state for all passcode to default
                if !isShowingError {
                    self.resetState()
                }
            } else {
                // apply fullPasscode from numeric keypad instead of saving currentPasscode
                // to make consistency between numeric keyPad component & passcode component
                self.selectedPasscodes = fullPasscode.map { String($0) }
            }

            guard let passcodeField = getPasscodeFields().first(
                where: { !$0.isFilled && $0.currentState != .filledState }) else {
                return
            }

            // Change color & run animation for this field
            animateScaleUp(passcodeField: passcodeField, completionHandler: nil)

            passcodeField.currentState = .filledState
            passcodeField.isFilled = true

            // handle in case all field was inputted
            self.handleInputtedAllFields()
        }
    }

    func handleDeleteAction() {
        guard let lastFilledField = getPasscodeFields().last(where: { $0.isFilled }) else {
            return
        }

        // Reset state for last field
        lastFilledField.isFilled = false
        lastFilledField.currentState = .defaultState

        // need remove last item here
        if !selectedPasscodes.isEmpty {
            selectedPasscodes.removeLast()
        }
    }
}
