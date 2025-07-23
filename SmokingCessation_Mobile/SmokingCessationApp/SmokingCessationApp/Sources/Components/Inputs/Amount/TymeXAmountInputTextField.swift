//
//  TymeXAmountInputTextField.swift
//  TymeComponent
//
//  Created by Tuan Tran on 05/10/2021.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

@IBDesignable
public class TymeXAmountInputTextField: TymeXBaseInputView {
    enum AmountHelper {
        case other
        case minMax(min: String, max: String)
    }

    // MARK: Views
    public lazy var textField = makeTextField()

    public var value: Double {
        get { textField.value }
        set {
            textField.value = newValue
            textField.sendActions(for: .editingChanged)
        }
    }

    public var currencySettings: TymeXCurrencySettings = TymeXCurrencySettings() {
        didSet {
            textField.currencySettings = currencySettings
        }
    }

    var amountStyle: AmountHelper = .other
    var amountWarningValue: Double?

    public var valueFromText: Double {
        return textField.value
    }

    // MARK: CallBacks
    public var onEndEdited: ((Double) -> Void)?
    public var onEditingText: ((Double) -> Void)?
    override func setupMiddleView() {
        middleContentView.addSubview(textField)
        guard let superView = textField.superview else {
            return
        }

        textField.mxAnchor(
            top: superView.topAnchor,
            bottom: superView.bottomAnchor,
            size: CGSize(width: 0, height: 48)
        )

        if let leftView = textField.leftView {
            leftView.mxAnchor(
                top: textField.topAnchor,
                leading: textField.leadingAnchor,
                bottom: textField.bottomAnchor,
                size: CGSize(width: SmokingCessation.spacing5, height: 0)
            )
        }

        let lConstraint = textField.leadingAnchor.constraint(greaterThanOrEqualTo: middleContentView.leadingAnchor)
        lConstraint.isActive = true

        let cConstraint = textField.centerXAnchor.constraint(equalTo: middleContentView.centerXAnchor)
        cConstraint.isActive = true

        self.textField.addTarget(self, action: #selector(textEditingChanged(_:)), for: .editingChanged)
        self.inputState = .loseFocus

        let tap = UITapGestureRecognizer(target: self, action: #selector(middleContentViewTapped(_:)))
        middleContentView.addGestureRecognizer(tap)

    }

    @objc func middleContentViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        self.textField.becomeFirstResponder()
    }

    public override func inputStateChanged() {
        super.inputStateChanged()
        textField.inputState = inputState
    }

    public override func updateMessageContentViews(
        _ str: String? = nil, withState: TymeXInputState? = nil
    ) {
        let state = withState ?? self.inputState
        let strValue = str ?? msgDefault.makeText() ?? ""
        var helperStyle: HelperStyle = .center(strValue)
        switch state {
        case .error, .filledError:
            guard strValue != "" else { return }
            helperStyle = .error(strValue)
        case .focus, .loseFocus:
            if case .minMax(let min, let max) = amountStyle {
                helperStyle = .leftRight(leftStr: min, rightStr: max)
            }
        }
        helperView.updateContentView(helperStyle)
        temptMsg = nil
    }

    public func updateShowMinMaxAmount(
        minValue: String,
        maxValue: String,
        amountWarning: Double? = nil,
        warningAmount: String? = nil
    ) {
        amountStyle = .minMax(min: minValue, max: maxValue)
        amountWarningValue = amountWarning
        msgDefault.setContent(.text(warningAmount))
        updateContentViews()
    }
}

// MARK: UITextfield methods
extension TymeXAmountInputTextField: UITextFieldDelegate {
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        addCustomKeyBoard()
    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard textField.text != nil else {
            return false
        }
        return (textField as? TymeXCurrencyTextField)?.shouldChangeCharacters(
            in: range, replacementString: string
        ) ?? false
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textField.textFieldDidBeginEditing(textField)
        if inputState != .error {
            inputState = .focus
        }
        guard let cTextfield = textField as? TymeXCurrencyTextField else { return }
        guard !(cTextfield.text?.isEmpty ?? true) else {
            cTextfield.updatePlaceHolder()
            return
        }
        let alwaysShowAsDecimal = shouldShowDecimal()
        cTextfield.displayValue(alwaysShowAsDecimal: alwaysShowAsDecimal)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        onEndEdited?(self.textField.value)
        if inputState != .error {
            inputState = .loseFocus
        }
        guard let cTextfield = textField as? TymeXCurrencyTextField else { return }
        guard !(cTextfield.text?.isEmpty ?? true) else { return }
        cTextfield.displayValue(alwaysShowAsDecimal: true)
    }

    @objc func textEditingChanged(_ textField: TymeXCurrencyTextField) {
        onEditingText?(textField.value)
        textField.textDidChange(textField)
        amountWarningChecking()
        inputState = .focus
    }

    private func shouldShowDecimal() -> Bool {
        guard let cTextfield = textField as? TymeXCurrencyTextField else { return false }
        let components = cTextfield.rawText.components(
            separatedBy: String(currencySettings.amountDecimalSeperator)
        )
        guard let lastComponentValue = Double(components.last ?? "0") else { return false }
        let shouldShowDecimal = (components.count == 2 && components.last?.count ?? 0 > 0 && lastComponentValue > 0)
        return shouldShowDecimal
    }
}

// MARK: Privates
extension TymeXAmountInputTextField {
    private func makeTextField() -> TymeXCurrencyTextField {
        let field = TymeXCurrencyTextField()
        field.delegate = self
        field.accessibilityIdentifier = "inputTextField-amount"
        return field
    }

    private func amountWarningChecking() {
        guard let valueWarning = amountWarningValue else {
            return
        }
        if valueFromText > valueWarning {
            helperView.updateContentView(
                .center(msgDefault.makeText() ?? "")
            )
        } else {
            updateMessageContentViews()
        }
    }

    private func addCustomKeyBoard() {
        let custom = TymeXCustomDecimalKeyboard()
        custom.translatesAutoresizingMaskIntoConstraints = false
        custom.delegate = textField
        custom.setDecimalSymbol(decimalSymbol: currencySettings.amountDecimalSeperator)
        textField.inputView = custom
    }
}
