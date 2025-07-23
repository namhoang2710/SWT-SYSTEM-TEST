//
//  FormatCurrentTextHelper.swift
//  TymeXUIComponent
//
//  Created by Vuong Tran on 02/01/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import UIKit

final class TymeXFormatCurrentTextHelper {
    var cursorHandler = TymeXCursorHandler()
    func shouldFormatValue(
        _ textField: UITextField,
        decimalSymbol: String,
        placeholderText: String
    ) -> Bool {
        guard let text = textField.text, text != placeholderText, !text.isEmpty else { return false }
        let components = text.components(separatedBy: decimalSymbol)

        return !(isIncompleteText(text: text, components: components, decimalSymbol: decimalSymbol)
                 && cursorHandler.isCursorAtEnd(of: textField))
            && !isCursorAtStartWithLeadingZero(textField: textField, components: components)
    }

    /**
     Incomplete text:
     ₱0 / ₱x. / ₱x.0 / ₱00000
     */
    func isIncompleteText(text: String, components: [String], decimalSymbol: String) -> Bool {
        return text.hasSuffix(decimalSymbol)
            || text == "0"
            || (components.count == 2 && components.last?.hasSuffix("0") == true)
            || (text.starts(with: "0") && text.hasSuffix(decimalSymbol))
    }

    // When user input ₱0 or insert 0 at the start of current text ₱xxxxx, wait for more input
    func isCursorAtStartWithLeadingZero(textField: UITextField, components: [String]) -> Bool {
        return cursorHandler.getOriginalCursorPosition(in: textField) == 1
            && components.first?.starts(with: "0") == true
    }
}
