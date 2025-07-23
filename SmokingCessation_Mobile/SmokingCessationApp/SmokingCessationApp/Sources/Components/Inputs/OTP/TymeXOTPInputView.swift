//
//  OTPInputView.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 23/07/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public final class TymeXOTPInputView: UIView {
    var currentTextField: TymeXOTPTextField?
    var accessibilityID: String?
    var shouldShowKeyboard: Bool = true
    public var completionHandler: ((String) -> Void)?
    struct Constants {
        static let bottomLineDefaultHeight: CGFloat = 2
        static let animationDuration: CFTimeInterval = AnimationDuration.duration3.value
        static let animationRepeatCount: Float = .infinity
        static let widthOTPTextField: CGFloat = 40
        static let spacingOTPTextField = SmokingCessation.spacing4
        static let heightStackView = 55.0
        static let widthErrorIcon = 16.0
    }

    lazy var inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.spacingOTPTextField
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

    private lazy var errorIcon: UIImageView = {
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

    lazy var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = SmokingCessation.colorStrokeSelect
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()

    lazy var hiddenTextField: TymeXHiddenTextField = {
        let hiddenTextField = TymeXHiddenTextField()
        hiddenTextField.keyboardType = .numberPad
        hiddenTextField.translatesAutoresizingMaskIntoConstraints = false
        hiddenTextField.isHidden = true
        if #available(iOS 12.0, *) {
            hiddenTextField.textContentType = .oneTimeCode
        }
        hiddenTextField.delegate = self
        hiddenTextField.onDeleteBackward = { [weak self] in
            self?.handleDeleteAction()
        }
        return hiddenTextField
    }()

    var numberOfFields: Int = TymeXOTPMode.fourDigits.numberOfFields {
        didSet {
            setupView()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    public init(
        mode: TymeXOTPMode, accessibilityID: String? = nil,
        shouldShowKeyboard: Bool = true
    ) {
        self.numberOfFields = mode.numberOfFields
        self.accessibilityID = accessibilityID
        self.shouldShowKeyboard = shouldShowKeyboard
        super.init(frame: .zero)
        setupView()
    }

    private func setupView() {
        setupStackViewInput()
        setupStackViewError()
        setupTextFieldsWithAnimation()
        setupBottomLine()
        setupHiddenTextField()
    }

    private func setupStackViewInput() {
        let widthInputStackView = CGFloat(numberOfFields) * Constants.widthOTPTextField +
                    CGFloat(numberOfFields - 1) * Constants.spacingOTPTextField
        addSubview(inputStackView)

        NSLayoutConstraint.activate([
            inputStackView.topAnchor.constraint(equalTo: self.topAnchor),
            inputStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            inputStackView.heightAnchor.constraint(equalToConstant: Constants.heightStackView),
            inputStackView.widthAnchor.constraint(equalToConstant: widthInputStackView)
        ])
    }

    private func setupStackViewError() {
        addSubview(errorStackView)
        NSLayoutConstraint.activate([
            errorIcon.widthAnchor.constraint(equalToConstant: Constants.widthErrorIcon),
            errorStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            errorStackView.topAnchor.constraint(equalTo: inputStackView.bottomAnchor, constant: SmokingCessation.spacing2),
            errorStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: self.leadingAnchor,
                constant: SmokingCessation.spacing4
            )
        ])
    }

    private func setupBottomLine() {
        updateBottomLineBackground(color: SmokingCessation.colorStrokeSelect)
        addSubview(bottomLine)
        if let firstOTPField = getTextFields().first {
            NSLayoutConstraint.activate([
                bottomLine.heightAnchor.constraint(equalToConstant: Constants.bottomLineDefaultHeight),
                bottomLine.bottomAnchor.constraint(equalTo: inputStackView.bottomAnchor),
                bottomLine.leadingAnchor.constraint(equalTo: firstOTPField.leadingAnchor),
                bottomLine.trailingAnchor.constraint(equalTo: firstOTPField.trailingAnchor)
            ])
        }
    }

    private func setupHiddenTextField() {
        addSubview(hiddenTextField)
        NSLayoutConstraint.activate([
            hiddenTextField.topAnchor.constraint(equalTo: self.topAnchor),
            hiddenTextField.leftAnchor.constraint(equalTo: self.leftAnchor),
            hiddenTextField.rightAnchor.constraint(equalTo: self.rightAnchor),
            hiddenTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    func setupTextFieldsWithAnimation() {
        // Remove all textFields
        inputStackView.mxRemoveAllSubviews()

        let totalDuration: TimeInterval = 0.36
        let fieldDuration = totalDuration / Double(numberOfFields)

        for index in 0..<numberOfFields {
            let textField = TymeXOTPTextField()

            // Set alpha to hide text field
            textField.alpha = 0
            inputStackView.addArrangedSubview(textField)

            // Create animator for display text field
            let animator = UIViewPropertyAnimator(duration: fieldDuration, curve: .easeInOut) {
                textField.alpha = 1.0
            }

            // start animation after a delay time
            animator.startAnimation(afterDelay: fieldDuration * Double(index))

            // setup accessibilityIdentifier
            textField.accessibilityIdentifier = "otpTextField_index_\(index)"
            textField.label.accessibilityIdentifier = "labelOTPTextField_index_\(index)"
        }
        // Set first responder for 1st text field after all textfields was added into inputStackView
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentTextField = getTextFields().first

            // Start to focus on text field
            if self.shouldShowKeyboard {
                focusOnLastTextField()
            }
        }
    }
}

extension TymeXOTPInputView: UITextFieldDelegate {
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            
            // Check if this is an OTP autofill (only happens on hiddenTextField)
            if textField == hiddenTextField && string.count == numberOfFields {
                autoFillOTP(string)
                return false
            }
            
            if string.count == 1 {
                handleAddAction(newText: string)
                return false
            }
            return true
        }
}
