//
//  TymeXExchangeInputAmountView+Public.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 31/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXExchangeInputAmountView {
    public func displayErrorMessage(with message: String, title: String? = nil, isInputSelected: Bool) {
        self.isInputSelected = isInputSelected
        configuration.title = title ?? configuration.title
        titleLabel.attributedText = NSAttributedString(
            string: configuration.title,
            attributes: SmokingCessation.textLabelDefaultXs.color(inputState.getTitleColor(
                isInputSelected: isInputSelected,
                isFirstResponder: inputAmountTextField.isFirstResponder,
                isAmountEmpty: inputAmountTextField.text?.isEmpty ?? true
            ))
        )

        inputState = .error
        errorStackView.isHidden = !isInputSelected
        errorLabel.attributedText = NSAttributedString(
            string: message,
            attributes: SmokingCessation.textLabelDefaultS.color(SmokingCessation.colorTextError)
        )
    }

    public func displayHelperMessage(_ message: String) {
        helperLabel.isHidden = message.isEmpty
        helperLabel.attributedText = NSAttributedString(
            string: message,
            attributes: SmokingCessation.textLabelDefaultS.color(SmokingCessation.colorTextSubtle)
        )
    }

    public func setInputState(with state: TymeXInputState) {
        inputState = state
    }

    public func isErrorState() -> Bool {
        inputState == .error || inputState == .filledError
    }

    public func setupMainStackView() {
        // Remove existing constraints if needed
        NSLayoutConstraint.deactivate(mainStackView.constraints)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        if configuration.isReceiver {
            mxAddBottomCorners(radius: SmokingCessation.cornerRadius3)

            // Add new constraints
            NSLayoutConstraint.activate([
                mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        } else {
            mxAddTopCorners(radius: SmokingCessation.cornerRadius3)

            // Add new constraints
            NSLayoutConstraint.activate([
                mainStackView.topAnchor.constraint(equalTo: topAnchor),
                mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
            ])
        }
    }

    // Set Title Text with Attributed String
    public func updateFooterTitle(
        _ text: String,
        icon: UIImage?,
        additionalText: String) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = icon
        imageAttachment.bounds = CGRect(
            x: 0, y: -3,
            width: 16, height: 16
        )
        let titleAttribute = SmokingCessation.textLabelDefaultS.color(SmokingCessation.colorTextDefault)
        let descriptionAttribute = SmokingCessation.textLabelEmphasizeS.color(SmokingCessation.colorTextDefault)
        let attributedString = NSMutableAttributedString(
            string: "\(text) ",
            attributes: titleAttribute
        )
        let imageString = NSAttributedString(attachment: imageAttachment)
        attributedString.append(NSMutableAttributedString(
            string: "\(additionalText) ",
            attributes: descriptionAttribute)
        )
        if icon != nil {
            attributedString.append(imageString)
        }
        footerTitleLabel.attributedText = attributedString
    }

    public func showDropDownIcon(flag: Bool) {
        dropDownIconImageView.isHidden = !flag
    }

    func showFlagIcon(flag: Bool) {
        flagIconImageView.isHidden = !flag
    }

    public func updateCurrencyFlag(currencyFlag: UIImage?, currencyName: String) {
        flagIconImageView.image = currencyFlag
        currencyLabel.text = currencyName
    }

    public func getFooterTitleLabel() -> UILabel {
        return footerTitleLabel
    }

    public func getHelperLabel() -> UILabel {
        return helperLabel
    }

    public func getDropDownIconImageView() -> UIImageView {
        return dropDownIconImageView
    }
}
