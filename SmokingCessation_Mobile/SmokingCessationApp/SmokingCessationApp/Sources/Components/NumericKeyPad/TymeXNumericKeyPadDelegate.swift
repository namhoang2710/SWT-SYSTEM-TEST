//
//  TymeXNumericKeyPadDelegate.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 06/01/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation

// Protocol defining the delegate for TymeXNumericKeyPad
public protocol TymeXNumericKeyPadDelegate: AnyObject {
    /// Function called to return the full passcode entered
    func numericKeyPadDidEnterPasscode(currentPasscode: String, fullPasscode: String)

    /// Function called when Touch ID is tapped
    func numericKeyPadDidTapTouchID()

    /// Function called when Face ID is tapped
    func numericKeyPadDidTapFaceID()

    /// Function called when the Back/Delete button is tapped
    func numericKeyPadDidTapDeleteButton(currentPasscode: String, fullPasscode: String)
}
