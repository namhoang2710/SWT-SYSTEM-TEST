//
//  TymeXPhoneInputView+Setup.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 05/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXPhoneInputView {
    func setupCountryCode() {
        middleContentView.addSubview(countryCodeView)
        countryCodeView.mxAnchor(
            top: middleContentView.topAnchor,
            leading: middleContentView.leadingAnchor,
            bottom: middleContentView.bottomAnchor,
            trailing: textView.leadingAnchor,
            padding: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: SmokingCessation.spacing2)
        )
        countryCodeView.onTap = { [weak self] in
            guard let self = self else { return }
            self.onTap?()
        }
    }

    func setupTextView() {
        middleContentView.addSubview(textView)
        textView.mxAnchor(
            top: middleContentView.topAnchor,
            bottom: middleContentView.bottomAnchor,
            trailing: rightButton.leadingAnchor
        )
        textView.textContainerInset = UIEdgeInsets(
            top: SmokingCessation.spacing1, left: 0,
            bottom: SmokingCessation.spacing1, right: 0
        )
        textView.keyboardType = .numberPad
    }

    func setupRightButton() {
        middleContentView.addSubview(rightButton)
        rightButton.mxAnchor(
            trailing: middleContentView.trailingAnchor,
            size: getRightButtonSize()
        )
        rightButton.mxAnchorCenter(yAxis: middleContentView.centerYAnchor)
    }

    func setupPlaceHolderLabel() {
        middleContentView.addSubview(placeHolderLabel)
        placeHolderLabel.mxAnchor(
            leading: textView.leadingAnchor,
            trailing: textView.trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0),
            size: CGSize(width: .zero, height: 32.0)
        )

        placeHolderTopConstraint = placeHolderLabel.topAnchor.constraint(equalTo: textView.topAnchor)
        placeHolderTopConstraint?.isActive = true
    }
}
