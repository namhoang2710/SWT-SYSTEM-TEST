//
//  TymeXHiddenTextField.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 21/09/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public class TymeXHiddenTextField: UITextField {
    var onDeleteBackward: (() -> Void)?

    // A flag to control keyboard dismissal
    public var allowDismissKeyboard: Bool = false

    public override func deleteBackward() {
        super.deleteBackward()
        onDeleteBackward?()
    }

    public override func resignFirstResponder() -> Bool {
        // Check if keyboard dismissal is allowed
        if allowDismissKeyboard {
            // Call the superclass implementation to dismiss the keyboard
            return super.resignFirstResponder()
        } else {
            // Prevent keyboard from dismissing
            return false
        }
    }

    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        // Check if the view is being removed from its current window
        if newWindow == nil {
            handleDissmissKeyboard()
        }
    }

    private func handleDissmissKeyboard() {
        allowDismissKeyboard = true
        _ = resignFirstResponder()
    }
}
