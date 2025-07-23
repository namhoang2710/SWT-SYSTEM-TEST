//
//  TymeXNumericKeyPad+Actions.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 31/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit


public extension TymeXNumericKeyPad {
    // MARK: - Button Actions
    @objc func keyTapped(_ sender: TymeXNumericButton) {
        guard let keyType = sender.keyType else { return }
        switch keyType {
        case .delete:
            handleDeleteKey()
        case .faceID:
            delegate?.numericKeyPadDidTapFaceID()
        case .touchID:
            delegate?.numericKeyPadDidTapTouchID()
        default:
            handleDefaultKey(keyType)
        }
    }

    @objc func keyPressed(_ sender: TymeXNumericButton) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [
                UIView.AnimationOptions.curveEaseIn,
                UIView.AnimationOptions.allowUserInteraction
            ],
            animations: {
                sender.backgroundColor = SmokingCessation.colorBackgroundInfoBase
            },
            completion: nil)
    }

    @objc func keyReleased(_ sender: TymeXNumericButton) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [
                UIView.AnimationOptions.curveEaseIn,
                UIView.AnimationOptions.allowUserInteraction
            ],
            animations: {
                sender.backgroundColor = .clear
            },
            completion: nil)
    }

    private func handleDeleteKey() {
        // Remove the last key from pressedKeys array if it's not empty
        if !pressedKeys.isEmpty {
            pressedKeys.removeLast()
        }
        delegate?.numericKeyPadDidTapDeleteButton(
            currentPasscode: "",
            fullPasscode: getPressedText()
        )
    }

    private func handleDefaultKey(_ keyType: TymeXKeyType) {
        // Append the selected key to the pressedKeys array
        pressedKeys.append(keyType)

        // Play haptic feedback to give user tactile confirmation
        TymeXHapticFeedback.medium.vibrate()

        delegate?.numericKeyPadDidEnterPasscode(
            currentPasscode: keyType.getText(),
            fullPasscode: getPressedText()
        )
    }
}
