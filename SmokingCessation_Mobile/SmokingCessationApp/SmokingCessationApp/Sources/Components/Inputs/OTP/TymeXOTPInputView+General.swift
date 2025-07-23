//
//  TymeXOTPInputView+General.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 30/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public extension TymeXOTPInputView {
    func getTextFields() -> [TymeXOTPTextField] {
        return self.inputStackView.arrangedSubviews as? [TymeXOTPTextField] ?? []
    }

    func getPreviousOTPTextField() -> TymeXOTPTextField? {
        for index in 0..<getTextFields().count {
            if getTextFields()[index] == currentTextField && index > 0 {
                return getTextFields()[index - 1]
            }
        }
        return getTextFields().first
    }

    func getNextOTPTextField() -> TymeXOTPTextField? {
        for index in 0..<getTextFields().count {
            if getTextFields()[index] == currentTextField && index < getTextFields().count - 1 {
                return getTextFields()[index + 1]
            }
        }
        return nil
    }

    func updateBottomLineBackground(color: UIColor) {
        bottomLine.backgroundColor = color
    }

    func isLastOTP() -> Bool {
        return getTextFields().last == currentTextField
    }

    func isTextEmpty() -> Bool {
        return currentTextField?.getText().isEmpty ?? false
    }

    func getOTP() -> String {
        return getTextFields().compactMap { $0.label.text }.joined()
    }

    func resetAndHideErrorState() {
        errorStackView.isHidden = true
        updateBottomLineBackground(color: SmokingCessation.colorStrokeSelect)
        playAnimationFocusState(strokeColor: SmokingCessation.colorStrokeSelect)
        for textField in getTextFields() {
            textField.currentState = .lostFocus
        }
    }

    func playAnimationFocusState(strokeColor: UIColor) {
        // remove old animation
        bottomLine.layer.removeAnimation(forKey: TymeXAnimationKey.focusAnimation)

        // add new animation
        let animation = AnimationMaker().makeOTPFieldHighlightBackground(
            fromColor: strokeColor,
            toColor: .clear,
            animationDuration: Constants.animationDuration,
            repeatCount: Constants.animationRepeatCount
        )
        bottomLine.layer.add(animation, forKey: TymeXAnimationKey.focusAnimation)
    }

    func moveBottomLine(to textField: TymeXOTPTextField) {
        // remove old constraints for bottomLine
        guard let superview = bottomLine.superview else { return }
        for constraint in superview.constraints {
            if constraint.firstItem as? UIView == bottomLine || constraint.secondItem as? UIView == bottomLine {
                superview.removeConstraint(constraint)
            }
        }

        // update new constraints for bottomLine
        NSLayoutConstraint.activate([
            bottomLine.heightAnchor.constraint(equalToConstant: Constants.bottomLineDefaultHeight),
            bottomLine.bottomAnchor.constraint(equalTo: inputStackView.bottomAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: textField.trailingAnchor)
        ])

        UIView.animate(withDuration: Constants.animationDuration) {
            self.layoutIfNeeded()
        }

        // Play animation for BottomLine
        playAnimationFocusState(strokeColor: SmokingCessation.colorStrokeSelect)
    }
}
