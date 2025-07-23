//
//  TymeXComboInputView+Setup.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 27/02/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXComboInputView {
    func updateSizeForCloseButton() {
        // Reset any existing transform
        rightButton.transform = .identity

        // Apply a scaling transform to make the button smaller
        let scaleTransform = CGAffineTransform(
            scaleX: 16.0 / rightButton.bounds.width,
            y: 16.0 / rightButton.bounds.height
        )
        rightButton.transform = scaleTransform
    }

    func updateSizeForRightButton() {
        // Reset any existing transform
        rightButton.transform = .identity

        // Apply a scaling transform to make the button larger
        let scaleTransform = CGAffineTransform(
            scaleX: 24.0 / rightButton.bounds.width,
            y: 24.0 / rightButton.bounds.height
        )
        rightButton.transform = scaleTransform
    }

    func scaleButtonToZero() {
        rightButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    }

    func updateRightButtonState() {
        if textView.isFirstResponder && !textView.text.isEmpty {
            updateSizeForCloseButton()
            rightButton.setImage(SmokingCessation().iconCancelFilled, for: .normal)
        } else {
            // update size 24x24 & image for rightIcon as default when losing focus
            updateSizeForRightButton()
            rightButton.setImage(rightIcon, for: .normal)
        }
    }
}
