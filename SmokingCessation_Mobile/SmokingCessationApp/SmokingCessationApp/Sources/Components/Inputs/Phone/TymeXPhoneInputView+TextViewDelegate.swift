//
//  TymeXCountryCodeView+TextViewDelegate.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 07/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXPhoneInputView {
    public override func textView(
        _ textView: UITextView, shouldChangeTextIn range: NSRange,
        replacementText text: String) -> Bool {
        // Handle return key
        if text == "\n" && returnKeyType != .default {
            onShouldReturn?()
            return false
        }

        // Check if the input is a paste operation and validate it(only numeric)
        if isPasteOperation(text) && !isNumericText(text) {
            // If the pasted text contains non-numeric characters, prevent the paste
            return false
        }

        // Format and trim the input text
        let formattedInput = formatInputValue(input: text).trimmingWhiteSpace()
        let currentText = textView.text as NSString
        let modifiedTextView = currentText.replacingCharacters(in: range, with: formattedInput).removeWhitespace
        let lengthCurrentText = (currentText as String).removeWhitespace.length

        // Check if the modified text exceeds the maximum length
        if checkExceedsMaxLength(
            formattedInput: formattedInput, modifiedTextView: modifiedTextView,
            range: range, lengthCurrentText: lengthCurrentText) {
            return false
        }

        // Replace input value and update helper message
        replaceInputValue(range, formattedInput)
        updateHelperMessage(text: modifiedTextView)
        return false
    }

    func checkExceedsMaxLength(
        formattedInput: String, modifiedTextView: String,
        range: NSRange, lengthCurrentText: Int) -> Bool {
        if let maxLength = self.limitCharacter, modifiedTextView.count > maxLength {
            // Calculate the number of characters that can be added
            let allowedLength = maxLength - lengthCurrentText + range.length
            if allowedLength > 0 {
                // Append only the allowed number of characters
                let allowedText = (formattedInput as NSString).substring(to: allowedLength)
                replaceInputValue(range, allowedText)
                updateHelperMessage(text: textView.text.removeWhiteSpaces())

                // Move the cursor to the end of the allowed text
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let newCursorPosition = textView.text.length
                    textView.selectedRange = NSRange(location: newCursorPosition, length: 0)
                }
            }

            // Provide feedback
            TymeXHapticFeedback.light.vibrate()
            mxShake()
            return true
        }
        return false
    }

    // Function to check if the operation is a paste
    func isPasteOperation(_ text: String) -> Bool {
        return text == UIPasteboard.general.string
    }

    // Function to check if the text is numeric
    func isNumericText(_ text: String) -> Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: text.removeWhitespace))
    }
}
