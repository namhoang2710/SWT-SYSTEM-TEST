//
//  TymeXCurrencyTextField.swift
//  ios-ui-components
//
//  Created by Duy Le on 14/06/2021.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable open class TymeXCurrencyTextField: UITextField {
    // MARK: public properties
    /// This computed property represents the current value of the text field as a Double.
    public var value: Double {
        get {
            let doubleValue = text?.toCurrencyValue(decimalSymbol: currencySettings.amountDecimalSeperator)
            return doubleValue ?? currencySettings.defaultValue
        }
        set {
            setAmount(newValue)
        }
    }
    /// This designated  property  is for `currencySymbol`' and input text
    var currencySettings: TymeXCurrencySettings = TymeXCurrencySettings() {
        didSet {
            currencySymbol.updateCurrencyLabel(currencySettings.currencySymbol)
            updatePlaceHolder()
        }
    }

    /// This property represents the current input state of the text field.
    public var inputState: TymeXInputState = .loseFocus {
        didSet {
            if inputState != oldValue {
                inputStateChanged()
            }
        }
    }

    public var rawText: String = ""

    // MARK: local and internal properties
    /// These properties represent the normal and min value of font size when scaling down.
    private let nonScaleFontSize: CGFloat = 48
    private var minScaleFontSize: CGFloat = 32
    private var isDisabledAdjustTextScaling: Bool = false

    /// Handles cursor positioning within the text field
    let cursorHandler = TymeXCursorHandler()

    /// Represents the currency symbol view in the text field
    let currencySymbol = TymeXCurrencySymbolView()

    /// Currency textfield text style
    let mainTextTypeSetting = SmokingCessation.textHeadingXxl

    /// Handle cursor when a decimal symbol is added
    var shouldAdjustCursorPositionForDecimal = false

    /// format the value as currency when the text is completeted, otherwise just display it and wait for more input
    private var shouldFormatValueOnInputChanged = true

    // MARK: initialize
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initTextField()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initTextField()
    }

    func initTextField() {
        tintColor = .clear
        contentMode = .center
        textAlignment = .center
        leftView = currencySymbol
        leftViewMode = currencySettings.showCurrencySymbol ? .always : .never
        leftView?.translatesAutoresizingMaskIntoConstraints = false
        adjustsFontSizeToFitWidth = true
        defaultTextAttributes = mainTextTypeSetting
        currencySymbol.updateCurrencyLabel(currencySettings.currencySymbol)
        setAmount(currencySettings.defaultValue)
    }

    func inputStateChanged() {
        if text?.isEmpty ?? true || (text == currencySettings.placeHolderText && !isFirstResponder) {
            setText(value: "")
            updatePlaceHolder()
            return
        }
        adjustTextColorByState()
    }

    // MARK: - Custom text field functions
    /**
     This function checks various conditions to determine whether the input is valid.
     It handles cursor positioning, deletion, exceeding digits, decimal symbol, and prevents two zeros at the beginning.
     - Parameters:
     - previousValue: The previous value of the currency text field.
     - toUpdateValue: The new value to update the currency text field with.
     - text: The current text in the text field.
     - toUpdateText: The new text to update the text field with.
     - replacementString: The string to replace in the text field.
     - Returns: A Boolean value indicating whether the input is valid.
     */
    func validateInput(
        previousValue: Double,
        toUpdateValue: Double,
        text: NSString,
        toUpdateText: String,
        replacementString: String
    ) -> Bool {
        shouldAdjustCursorPositionForDecimal = false
        if toUpdateText == String(currencySettings.amountDecimalSeperator) {
            mxShake()
            return false
        }
        if !handleDeleteKey(
            previousValue: previousValue,
            toUpdateValue: toUpdateValue,
            text: text,
            toUpdateText: toUpdateText
        ) { return false }
        if isDeletionOperation(toUpdateText: toUpdateText) { return true }
        if !handleExceedingDigits(toUpdateText: toUpdateText) { return false }
        if !isDecimalSymbolUsageValid(toUpdateText: toUpdateText, replacementString: replacementString) { return false }
        if !handlePreventTwoZeroAtBeginning(toUpdateText: toUpdateText) { return false }

        shouldAdjustCursorPositionForDecimal = replacementString == String(currencySettings.amountDecimalSeperator)
        return true
    }

    /**
     Handles the delete key event for the text field.
     - Parameters:
     - previousValue: The previous value of the text field.
     - toUpdateValue: The new value to update the text field with.
     - text: The previous text of the text field.
     - toUpdateText: The new text to update the text field with.

     - Returns: A Boolean value indicating whether the text field should be updated.
     If the number of decimal group symbols in the new text is less than in the previous text,
     the cursor position is set back by one and the function returns `false`.
     Otherwise, the function returns `true`.
     */
    func handleDeleteKey(
        previousValue: Double,
        toUpdateValue: Double,
        text: NSString,
        toUpdateText: String
    ) -> Bool {
        let decimalGroupSymbol = currencySettings.amountWholeValueSeparator
        let toUpdateTextCounted = (toUpdateText as String).count(of: decimalGroupSymbol)
        if previousValue == toUpdateValue
            && toUpdateTextCounted < (text as String).count(of: decimalGroupSymbol) {
            cursorHandler.setCursorPosition(in: self, offset: -1)
            return false
        }
        return true
    }

    /// Determines whether a deletion operation is being performed.
    func isDeletionOperation(toUpdateText: String) -> Bool {
        if toUpdateText.count < text?.count ?? 0 {
            return true
        }
        return false
    }

    /// This function checks if the decimal symbol is used correctly in the input text.
    /// It ensures that there's only one decimal symbol and that the number of digits after the decimal symbol
    /// doesn't exceed the maximum allowed fraction digits.
    func isDecimalSymbolUsageValid(toUpdateText: String, replacementString: String) -> Bool {
        let decimalSymbolcount = (toUpdateText as String).count(of: currencySettings.amountDecimalSeperator)
        if decimalSymbolcount > 1 {
            mxShake()
            return false
        }

        let components = toUpdateText.components(
            separatedBy: currencySettings.amountDecimalSeperator
        )
        if components.count == 2 && (components.last?.count ?? .zero) > currencySettings.maximumFractionDigits {
            TymeXHapticFeedback.light.vibrate()
            mxShake()
            if !replacementString.contains(currencySettings.amountDecimalSeperator) {
                return false
            }
        }
        return true
    }

    /// This function checks if the count of digits in `toUpdateText` exceeds the `maxDigits`
    /// defined in `currencySettings`.
    /// If it does, it triggers a shake animation and returns false.
    func handleExceedingDigits(toUpdateText: String) -> Bool {
        let currentDigitString = toUpdateText.components(
            separatedBy: CharacterSet(charactersIn: "0123456789.").inverted
        ).joined()

        if currentDigitString.count > currencySettings.maxDigits {
            TymeXHapticFeedback.light.vibrate()
            mxShake()
            return false
        }
        return true
    }

    /// This function prevents the text from starting with two zeros.
    func handlePreventTwoZeroAtBeginning(toUpdateText: String) -> Bool {
        if toUpdateText.hasPrefix("00") {
            TymeXHapticFeedback.light.vibrate()
            mxShake()
            return false
        }
        return true
    }

    /// Handles text changes in the text field.
    /// This function updates the placeholder, determines whether to reformat the value,
    /// and handles the text change and cursor position.
    public func textDidChange(_ textField: UITextField) {
        updatePlaceHolder()
        let cursorOffset = cursorHandler.getOriginalCursorPosition(in: self)
        let text = textField.text ?? ""

        shouldFormatValueOnInputChanged = TymeXFormatCurrentTextHelper().shouldFormatValue(
            textField,
            decimalSymbol: currencySettings.amountDecimalSeperator,
            placeholderText: currencySettings.placeHolderText
        )

        if shouldAdjustCursorPositionForDecimal && !text.hasSuffix(currencySettings.amountDecimalSeperator) {
            shouldFormatValueOnInputChanged = true
        }

        handleTextChange(text: text, cursorOffset: cursorOffset)
    }

    /**
     Handles changes in the text field's text.
     - Parameter text: The new text in the text field.
     - Parameter cursorOffset: The original cursor position.
     */
    func handleTextChange(text: String, cursorOffset: Int) {
        guard !text.isEmpty else { return }
        if shouldFormatValueOnInputChanged {
            setAmount(value)
        } else {
            displayText(value: text)
        }
        handleCursorPosition(text: text, cursorOffset: cursorOffset)
    }

    /**
     Adjusts the cursor position based on the text and cursor offset.
     - Parameter text: The current text in the text field.
     - Parameter cursorOffset: The original cursor position.
     */
    func handleCursorPosition(text: String, cursorOffset: Int) {
        if !shouldAdjustCursorPositionForDecimal {
            cursorHandler.setCursorOriginalPosition(
                in: self,
                cursorOffset,
                oldTextFieldLength: text.count
            )
        } else {
            cursorHandler.handleCursorWithDot(
                in: self,
                offset: 1,
                decimalSymbol: currencySettings.amountDecimalSeperator
            )
        }
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        // This is empty for inherited class to override and implement
    }

    // MARK: - Text formatting functions

    /// Sets the amount in the text field.
    /// If the amount is the default value, the text field is cleared and the placeholder is updated.
    /// Otherwise, the amount is formatted and displayed in the text field.
    func setAmount(_ amount: Double, alwaysShowAsDecimal: Bool = false) {
        let decimalNumber = adjustMinDecimalNumber(alwaysShowAsDecimal: alwaysShowAsDecimal)
        if amount == currencySettings.defaultValue {
            setText(value: "")
            updatePlaceHolder()
        } else if let stringValue = currencySettings.format(
            value: amount,
            minimumFractionDigits: decimalNumber
        ) {
            displayText(value: stringValue)
        }
    }

    func adjustMinDecimalNumber(alwaysShowAsDecimal: Bool) -> Int {
        if !alwaysShowAsDecimal {
            return 0
        }
        let components = text?.components(separatedBy: String(currencySettings.amountDecimalSeperator)
        )
        guard components?.count == 2 else { return currencySettings.minimumFractionDigits }
        var decimalNumber = components?.last?.count ?? 0
        if decimalNumber < currencySettings.minimumFractionDigits {
            decimalNumber = currencySettings.minimumFractionDigits
        }
        return decimalNumber
    }

    /// Display as decimal format  when user did end inputting, ie. 5.00
    /// Display as short version  when user start inputting or not enough space for displaying as decimal ie. 5
    /// The result is the same if currencySettings is set with minimumFractionDigits = 0
    public func displayValue(alwaysShowAsDecimal: Bool) {
        setAmount(value, alwaysShowAsDecimal: alwaysShowAsDecimal)

        // if textWidth is still bigger than its content, ignore decimal
        let shouldIgnoreDecimal = shouldAdjustTextWidth(
            font: font,
            width: bounds.width - SmokingCessation.spacing6
        )
        if alwaysShowAsDecimal && shouldIgnoreDecimal {
            setAmount(value, alwaysShowAsDecimal: false)
        }
    }

    public func disableAdjustTextScaling() {
        minScaleFontSize = .zero
        isDisabledAdjustTextScaling = true
    }

    /// Updates the placeholder based on the current text and input state
    public func updatePlaceHolder() {
        if text != "" {
            placeholder = ""
        } else {
            let prefixColor = inputState.currencySymbolColor
            let placeHodlerColor = inputState.getPlaceHolderColor(isTyping: isFirstResponder)
            attributedPlaceholder = NSAttributedString(
                string: currencySettings.placeHolderText,
                attributes: [NSAttributedString.Key.foregroundColor: placeHodlerColor]
            )
            currencySymbol.setColor(color: prefixColor)
            tintColor =  prefixColor
        }
        layoutSubviews()
        adjustTextScaling()
    }

    /// Displays the given value and adjusts the text color & scaling based on the input state
    func displayText(value: String = "") {
        setText(value: value)
        layoutIfNeeded()
        adjustTextColorByState()
        adjustTextScaling()
    }

    func setText(value: String = "") {
        rawText = text ?? ""
        text = value
    }

    /// Adjusts the text color based on the current input state
    func adjustTextColorByState() {
        let color = inputState.colorInputField
        textColor = color
        tintColor = color
        currencySymbol.setColor(color: color)
    }

    func shouldAdjustTextWidth(font: UIFont?, width: CGFloat) -> Bool {
        guard let text = text,
              let font = font else {
            return false
        }
        let textWidth = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width
        return textWidth >= width && value != currencySettings.defaultValue
    }

    /// Adjusts the text scaling based on the current frame width and value
    func adjustTextScaling() {
        guard !isDisabledAdjustTextScaling else { return }
        let spacingBig: CGFloat = 64.0
        let shouldAdjustTextScaling = shouldAdjustTextWidth(
            font: mainTextTypeSetting[.font] as? UIFont,
            width: (superview?.bounds.width ?? 0) - spacingBig
        )
        minimumFontSize = shouldAdjustTextScaling ? minScaleFontSize : nonScaleFontSize
        layoutSubviews()
    }
}
