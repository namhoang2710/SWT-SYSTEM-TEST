//
//  TymeXPasscodeInputView+Setup.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 16/01/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXPasscodeInputView {
    func setupView() {
        setupStackViewInput()
        setupPasscodeFields()
        setupStackViewError()
        setupHelperText()
    }

    func setupStackViewInput() {
        let widthInputStackView = CGFloat(numberOfFields) * ConstantsPasscode.widthPasscodeField +
                    CGFloat(numberOfFields - 1) * ConstantsPasscode.spacingPasscodeField
        addSubview(inputStackView)

        NSLayoutConstraint.activate([
            inputStackView.topAnchor.constraint(equalTo: self.topAnchor),
            inputStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            inputStackView.heightAnchor.constraint(equalToConstant: ConstantsPasscode.heightStackView),
            inputStackView.widthAnchor.constraint(equalToConstant: widthInputStackView)
        ])
    }

    func setupStackViewError() {
        addSubview(errorStackView)
        NSLayoutConstraint.activate([
            errorIcon.widthAnchor.constraint(equalToConstant: ConstantsPasscode.widthErrorIcon),
            errorStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            errorStackView.topAnchor.constraint(equalTo: inputStackView.bottomAnchor, constant: SmokingCessation.spacing1),
            errorStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: self.leadingAnchor,
                constant: SmokingCessation.spacing4
            )
        ])
    }

    func setupPasscodeFields() {
        // Remove all textFields
        inputStackView.mxRemoveAllSubviews()
        for index in 0..<numberOfFields {
            let passcodeField = TymeXPasscodeField()

            // Set alpha to hide text field
            inputStackView.addArrangedSubview(passcodeField)

            // setup accessibilityIdentifier
            passcodeField.accessibilityIdentifier = "passcodeField_index_\(index)"
            passcodeField.circleView.accessibilityIdentifier = "circleViewTymeXPasscodeField_index_\(index)"
        }
    }

    func setupHelperText() {
        addSubview(helperTextLabel)
        NSLayoutConstraint.activate([
            helperTextLabel.topAnchor.constraint(equalTo: inputStackView.bottomAnchor, constant: SmokingCessation.spacing1),
            helperTextLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            helperTextLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: self.leadingAnchor,
                constant: SmokingCessation.spacing4
            )
        ])
    }
}
