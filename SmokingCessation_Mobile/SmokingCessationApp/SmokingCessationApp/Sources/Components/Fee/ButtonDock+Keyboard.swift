//
//  ButtonDock+Keyboard.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

extension ButtonDock {
    func registerKeyboard() {
        if allowHandleKeyboard {
            NotificationCenter.default.addObserver(
                self, selector: #selector(keyboardWillShow(_:)),
                name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(
                self, selector: #selector(keyboardWillHide(_:)),
                name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if displayMode == .onlyShowSeperatorWhenFocus {
            lineView.isHidden = false
        }
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height

            // Get height of safe area at the bottom
            let safeAreaInsets = UIDevice.current.safeAreaInset.bottom

            // Adjust height keyboard with remove safeAreaInsets bottom
            let adjustedKeyboardHeight = (keyboardHeight - safeAreaInsets + 16)
            adjustViewForKeyboard(height: adjustedKeyboardHeight)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if displayMode == .onlyShowSeperatorWhenFocus {
            lineView.isHidden = true
        }
        let bottomSpacing = UIDevice.current.hasHomeIndicator ? 0 : 16.0
        adjustViewForKeyboard(height: bottomSpacing)
    }

    private func adjustViewForKeyboard(height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.containerViewBottomConstraint.constant = -height
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
}
