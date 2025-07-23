//
//  TymeXNumericKeyPad+Public.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 01/01/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation

public protocol TymeXNumericKeyPadProtocol: AnyObject {
    func getPressedText() -> String
    func updatePressedKeys(newPasscode: String)
    func clearText()
    func showBiometricButton(flag: Bool)
}

extension TymeXNumericKeyPad: TymeXNumericKeyPadProtocol {
    public func getPressedText() -> String {
        return pressedKeys.compactMap { keyType in
            if case .number(let value) = keyType {
                return value
            }
            return nil
        }.joined()
    }

    public func clearText() {
        pressedKeys = []
    }

    public func updatePressedKeys(newPasscode: String) {
        pressedKeys = [.number(newPasscode)]
    }

    public func showBiometricButton(flag: Bool) {
        guard let biometricButton = biometricButton else { return }
        biometricButton.alpha = flag ? 1 : 0
        biometricButton.isUserInteractionEnabled = flag
    }
}
