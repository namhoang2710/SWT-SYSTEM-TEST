//
//  ExchangeInputAmountView.swift
//  InternationalTransfer
//
//  Created by Duy Le on 24/7/24.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public final class TymeXExchangeInputAmountView: UIView {
    // MARK: - LifeCycle
    public init(configuration: TymeXExchangeInputAmountConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupUI()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    public var onEndEdited: ((Double) -> Void)?
    public var onBeginEditing: (() -> Void)?
    public var onValueChanged: ((Double) -> Void)?
    public var onEstimatedArrivalTapped: (() -> Void)?
    public var onDropDownIconTapped: (() -> Void)?

    public var value: Double {
        get { inputAmountTextField.value }
        set {
            inputAmountTextField.value = newValue
        }
    }

    // MARK: - Private
    public var configuration: TymeXExchangeInputAmountConfiguration {
        didSet {
            makeUpUI()
        }
    }
    var isInputSelected: Bool = false
    var inputState: TymeXInputState = .loseFocus {
        didSet {
            inputAmountTextField.inputState = isInputSelected ? inputState : .loseFocus
            makeUpUI()
            if !isErrorState() {
                errorStackView.isHidden = true
            } else {
                if inputState == .error && isInputSelected {
                    TymeXHapticFeedback.error.vibrate()
                    inputAmountTextField.mxShake()
                }
            }
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    lazy var footerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = SmokingCessation.spacing1
        stackView.addArrangedSubview(footerTitleLabel)
        return stackView
    }()

    var footerTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(inputAmountView)
        stackView.addArrangedSubview(estimatedArrivalView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var inputAmountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = SmokingCessation.spacing3
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(inputStackView)
        stackView.addArrangedSubview(errorStackView)
        stackView.addArrangedSubview(helperLabel)
        return stackView
    }()

    lazy var inputAmountView: UIView = {
        let view = UIView()
        view.addSubview(inputAmountStackView)
        inputAmountStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputAmountStackView.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: configuration.isReceiver ? SmokingCessation.spacing6 : SmokingCessation.spacing4
            ),
            inputAmountStackView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -SmokingCessation.spacing4
            ),
            inputAmountStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: SmokingCessation.spacing4
            ),
            inputAmountStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -SmokingCessation.spacing4
            )
        ])
        return view
    }()

    lazy var currencyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = SmokingCessation.spacing1
        stackView.addArrangedSubview(flagIconImageView)
        stackView.addArrangedSubview(currencyLabel)
        stackView.addArrangedSubview(dropDownIconImageView)
        stackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return stackView
    }()

    public var flagIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        return imageView
    }()

    public var dropDownIconImageView: UIImageView = {
        let dropdownImageView = UIImageView()
        dropdownImageView.contentMode = .scaleAspectFit
        dropdownImageView.tintColor = UIColor.black
        NSLayoutConstraint.activate([
            dropdownImageView.widthAnchor.constraint(equalToConstant: 16)
        ])
        return dropdownImageView
    }()

    lazy var inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = SmokingCessation.spacing1
        stackView.addArrangedSubview(inputAmountTextField)
        stackView.addArrangedSubview(currencyStackView)
        NSLayoutConstraint.activate([
            inputAmountTextField.heightAnchor.constraint(equalToConstant: 30)
        ])
        return stackView
    }()

    lazy var inputAmountTextField: TymeXCurrencyTextField = {
        let textField = TymeXCurrencyTextField()
        textField.disableAdjustTextScaling()
        textField.delegate = self
        textField.leftViewMode = .never
        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }()

    lazy var errorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isHidden = true
        stackView.axis = .horizontal
        stackView.spacing = SmokingCessation.spacing1
        stackView.addArrangedSubview(errorIconImageView)
        stackView.addArrangedSubview(errorLabel)
        return stackView
    }()

    var errorIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = SmokingCessation().iconError?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = SmokingCessation.colorTextError
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: SmokingCessation.spacing4),
            imageView.heightAnchor.constraint(equalToConstant: SmokingCessation.spacing4)
        ])
        return imageView
    }()

    lazy var helperLabel: UILabel = {
        let helperLabel = UILabel()
        helperLabel.numberOfLines = 0
        helperLabel.isHidden = true
        return helperLabel
    }()

    lazy var estimatedArrivalView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = SmokingCessation.colorStrokeInfoBase
        view.addSubview(footerStackView)
        footerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: SmokingCessation.spacing3),
            footerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -SmokingCessation.spacing3),
            footerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SmokingCessation.spacing4),
            footerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SmokingCessation.spacing4)
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didEstimatedArrivalTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    var mainStackViewTopConstraint: NSLayoutConstraint!
    var mainStackViewBottomConstraint: NSLayoutConstraint!

    // Function to check if the operation is a paste
    func isPasteOperation(_ text: String) -> Bool {
        return text == UIPasteboard.general.string
    }

    // Function to check if the text is numeric
    func isNumericText(_ text: String) -> Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: text.removeWhitespace))
    }
}

extension TymeXExchangeInputAmountView: UITextFieldDelegate {
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard textField.text != nil else {
            return false
        }

        // Check if the input is a paste operation and validate it(only numeric)
        if isPasteOperation(string) && !isNumericText(string) {
            // If the pasted text contains non-numeric characters, prevent the paste
            return false
        }

        return inputAmountTextField.shouldChangeCharacters(in: range, replacementString: string)
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        onBeginEditing?()
        if inputState != .error {
            inputState = .focus
        }
        guard !(inputAmountTextField.text?.isEmpty ?? true) else {
            inputAmountTextField.updatePlaceHolder()
            return
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        onEndEdited?(inputAmountTextField.value)
        if inputState != .error {
            inputState = .loseFocus
        }
        if inputState == .error {
            inputState = .filledError
        }
        guard !(inputAmountTextField.text?.isEmpty ?? true) else { return }
        inputAmountTextField.displayValue(alwaysShowAsDecimal: true)
    }

    @objc func textEditingChanged(_ textField: TymeXCurrencyTextField) {
        onValueChanged?(textField.value)
        textField.textDidChange(textField)
        if inputState != .error {
            inputState = .focus
        }
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        let custom = TymeXCustomDecimalKeyboard()
        custom.translatesAutoresizingMaskIntoConstraints = false
        custom.delegate = inputAmountTextField
        custom.setDecimalSymbol(decimalSymbol: SmokingCessation.amountLocalDecimalSeperator)
        inputAmountTextField.inputView = custom
    }
}
