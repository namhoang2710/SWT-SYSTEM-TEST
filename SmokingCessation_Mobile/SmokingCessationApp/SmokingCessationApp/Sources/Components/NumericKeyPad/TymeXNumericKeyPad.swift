//
//  TymeXNumericKeypad.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 31/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import UIKit


public class TymeXNumericKeyPad: UIView {
    var widthNumber: CGFloat = 72
    
    // array to save pressed keys
    var pressedKeys: [TymeXKeyType] = []
    public weak var delegate: TymeXNumericKeyPadDelegate?
    var accessibilityID: String?
    // bio mode
    var biometricMode = TymeXKeypadBiometricMode.faceID
    var backSpaceMode = TymeXKeypadBackspaceMode.back
    var numericKeyboardMode = TymeXNumericKeyboardMode.fourDigits
    
    // Store reference to biometric button
    var biometricButton: TymeXNumericButton?
    
    var keys: [[TymeXKeyType]] {
        [
            [.number("1"), .number("2"), .number("3")],
            [.number("4"), .number("5"), .number("6")],
            [.number("7"), .number("8"), .number("9")],
            [shouldShowBioKey() ? getBioKeyType() : .none,
             .number("0"),
             shouldBackSpaceKey() ? .delete : .none]
        ]
    }
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = SmokingCessation.spacing5
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public init(
        bioMode: TymeXKeypadBiometricMode,
        backspaceMode: TymeXKeypadBackspaceMode,
        keyboardMode: TymeXNumericKeyboardMode,
        widthNumber: CGFloat = 72,
        accessibilityID: String? = nil
    ) {
        super.init(frame: .zero)
        self.accessibilityID = accessibilityID
        self.widthNumber = widthNumber
        biometricMode = bioMode
        backSpaceMode = backspaceMode
        numericKeyboardMode = keyboardMode
        setupView()
    }
    
    private func getBioKeyType() -> TymeXKeyType {
        return biometricMode == .faceID ? .faceID : .touchID
    }
    
    private func shouldShowBioKey() -> Bool {
        return biometricMode != .none
    }
    
    private func shouldBackSpaceKey() -> Bool {
        return backSpaceMode != .none
    }
}

public class TymeXNumericButton: UIButton {
    var keyType: TymeXKeyType?
}
