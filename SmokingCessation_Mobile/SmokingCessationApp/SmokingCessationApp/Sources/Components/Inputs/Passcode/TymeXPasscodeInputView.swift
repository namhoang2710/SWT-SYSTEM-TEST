//
//  TymeXPasscodeInputView.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 30/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public final class TymeXPasscodeInputView: UIView {
    var numberOfFields: Int = TymeXPasscodeMode.fourDigits.numberOfFields {
        didSet {
            setupView()
        }
    }
    var accessibilityID: String?
    public var completionHandler: ((String) -> Void)?
    var isShowingError: Bool = false
    var selectedPasscodes: [String] = []
    struct ConstantsPasscode {
        static let widthPasscodeField: CGFloat = 40
        static let spacingPasscodeField = 0.0
        static let heightStackView = 44.0
        static let widthErrorIcon = 16.0
        static let scaleWidthRatio = 1.3
        static let animationDuration = 0.1
    }

    public var numericKeypad: TymeXNumericKeyPad?
    lazy var inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = ConstantsPasscode.spacingPasscodeField
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var errorStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [errorIcon, errorMessageLabel])
        stackView.axis = .horizontal
        stackView.spacing = SmokingCessation.spacing1
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        return stackView
    }()

    lazy var errorIcon: UIImageView = {
        let imageView = UIImageView(image: SmokingCessation().iconError?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = SmokingCessation.colorIconDefaultExtra
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var helperTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    public init(
        mode: TymeXPasscodeMode,
        numericKeypad: TymeXNumericKeyPad,
        accessibilityID: String? = nil
    ) {
        self.numberOfFields = mode.numberOfFields
        self.numericKeypad = numericKeypad
        self.accessibilityID = accessibilityID
        super.init(frame: .zero)
        setupView()
    }

    func getPasscodeFields() -> [TymeXPasscodeField] {
        return inputStackView.arrangedSubviews.compactMap { $0 as? TymeXPasscodeField }
    }

    func isFilledAllPasscode() -> Bool {
        let passcodeField = getPasscodeFields().first(where: { !$0.isFilled })
        return passcodeField == nil
    }

    func resetPasscodeList() {
        selectedPasscodes = []
        numericKeypad?.clearText()
    }

    func updateListPasscode(newPasscode: String) {
        selectedPasscodes = [newPasscode]
        numericKeypad?.updatePressedKeys(newPasscode: newPasscode)
    }

    func showErrorStatesUI() {
            for passcodeField in self.getPasscodeFields() {
                passcodeField.currentState = .errorState
                passcodeField.mxShake()
            }
    }

    func resetErrorStateToDefault(isHiddenErrorMessage: Bool = true) {
        // hide error message
        hideErrorMessage(flag: isHiddenErrorMessage)

        // play animation from right -> left
        playAnimationForAllFields()
    }

    func playAnimationForAllFields() {
            let passcodeFields = self.getPasscodeFields()
            // Iterate from right to left (reverse order)
            for (index, passcodeField) in passcodeFields.reversed().enumerated() {
                let delay = Double(index) * 0.1
                UIView.animate(
                    withDuration: 0.3,
                    delay: delay, options: .curveEaseIn, animations: {
                        passcodeField.currentState = .defaultState
                        passcodeField.isFilled = false
                })
            }
    }

    func hideErrorMessage(flag: Bool) {
        errorStackView.isHidden = flag
    }

    func handleInputtedAllFields() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Check all fields whether there is filled or not
            let allFields = self.inputStackView.arrangedSubviews.compactMap { $0 as? TymeXPasscodeField }
            if allFields.allSatisfy({ $0.isFilled }) {
                self.completionHandler?(getSelectedPasscode())
            }
        }
    }
}
