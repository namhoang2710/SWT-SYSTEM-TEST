//
//  TymeXCurrencyTextField + Extension.swift
//  TymeXUIComponent
//
//  Created by Thao Lai on 15/03/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXCurrencyTextField: CustomDecimalKeyboardDelegate {

    /// This function determines whether the specified text should be replaced in the text field.
    public func shouldChangeCharacters(
        in range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = text, text.containsRange(range) else { return false }
        guard let currentText = text as NSString? else { return false }

        let toUpdateText = currentText.replacingCharacters(in: range, with: string)
        let previousValue = self.text?.toCurrencyValue(
            decimalSymbol: currencySettings.amountDecimalSeperator
        ) ?? currencySettings.defaultValue
        let toUpdateValue =  toUpdateText.toCurrencyValue(decimalSymbol: currencySettings.amountDecimalSeperator)

        return validateInput(
            previousValue: previousValue,
            toUpdateValue: toUpdateValue,
            text: currentText,
            toUpdateText: toUpdateText,
            replacementString: string
        )
    }

    public func handleCustomeKeyboardDeleteKey() {
        shouldAdjustCursorPositionForDecimal = false
        guard let text = text, !text.isEmpty else {
            super.deleteBackward()
            return
        }

        // Get the cursor position
        guard let selectedRange = self.selectedTextRange else { return }
        var cursorPosition = offset(from: beginningOfDocument, to: selectedRange.start)

        // Check if the cursor is at the start of the text field
        if cursorPosition == 0 {
            return
        }

        // Get the character at the previous index
        let previousCharacterIndex = text.index(text.startIndex, offsetBy: cursorPosition - 1)
        let previousCharacter = text[previousCharacterIndex]

        // Check if the previous character is the currency group symbol
        let currencyGroupSymbol = currencySettings.amountWholeValueSeparator
        if String(previousCharacter) == currencyGroupSymbol {
            // Move the cursor one position left
            cursorPosition -= 1
            if let newPosition = position(from: beginningOfDocument, offset: cursorPosition) {
                selectedTextRange = textRange(from: newPosition, to: newPosition)
            }
            return
        }
        super.deleteBackward()
    }
}
