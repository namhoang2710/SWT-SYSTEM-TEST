//
//  TymeXExchangeInputAmountView+Setup.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 31/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXExchangeInputAmountView {
    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didViewTapped))
        addGestureRecognizer(tapGesture)
        addSubview(mainStackView)
        inputAmountTextField.addTarget(self, action: #selector(textEditingChanged(_:)), for: .editingChanged)
        makeRoundCorner(size: SmokingCessation.cornerRadius3)

        mainStackViewTopConstraint = mainStackView.topAnchor.constraint(equalTo: topAnchor)
        mainStackViewBottomConstraint = mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor)

        NSLayoutConstraint.activate([
            mainStackViewTopConstraint,
            mainStackViewBottomConstraint,
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        makeUpUI()
    }

    func makeUpUI() {
        titleLabel.attributedText = NSAttributedString(
            string: configuration.title,
            attributes: SmokingCessation.textLabelDefaultXs.color(inputState.getTitleColor(
                isInputSelected: isInputSelected,
                isFirstResponder: inputAmountTextField.isFirstResponder,
                isAmountEmpty: inputAmountTextField.text?.isEmpty ?? true
            ))
        )
        currencyLabel.attributedText = NSAttributedString(
            string: configuration.currencyType.title,
            attributes: SmokingCessation.textTitleL
        )
        flagIconImageView.image = configuration.currencyType.flagIcon
        flagIconImageView.isHidden = (configuration.currencyType.flagIcon == nil)
        dropDownIconImageView.image = SmokingCessation().iconChevronDown
        dropDownIconImageView.isHidden = configuration.isHiddenDropDownIcon
        estimatedArrivalView.isHidden = !configuration.isReceiver
        makeBorder(inputState.borderColor)
        inputAmountTextField.defaultTextAttributes = SmokingCessation.textHeadingL.color(
            inputState.getAmountColor(
                isInputSelected: isInputSelected
            )
        )
        inputAmountTextField.tintColor = inputState.getAmountColor(
            isInputSelected: isInputSelected
        )
    }

    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDropDownIconTapped))
        currencyStackView.addGestureRecognizer(tapGesture)
    }

    @objc func handleDropDownIconTapped() {
        // Call the onTap closure if it is set
        if !dropDownIconImageView.isHidden {
            onDropDownIconTapped?()
        }
    }
}
