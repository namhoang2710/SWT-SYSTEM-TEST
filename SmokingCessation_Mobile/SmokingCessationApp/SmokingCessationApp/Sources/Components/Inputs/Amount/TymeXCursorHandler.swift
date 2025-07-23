//
//  CursorHandler.swift
//  TymeXUIComponent
//
//  Created by Thao Lai on 04/02/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

class TymeXCursorHandler {
    /**
     Sets the cursor to the last index of the text in the given text field.

     - Parameter textField: The text field to handle.
     */
    public func handleCursorWithLastIndex(in textField: UITextField) {
        textField.selectedTextRange = textField.textRange(
            from: textField.beginningOfDocument,
            to: textField.beginningOfDocument
        )
        setCursorPosition(in: textField, offset: textField.text?.count ?? 0)
    }

    /**
     Sets the cursor to the position after the decimal symbol in the given text field.

     - Parameters:
       - textField: The text field to handle.
       - offset: The offset from the decimal symbol where the cursor should be placed.
     */
    func handleCursorWithDot(in textField: UITextField, offset: Int, decimalSymbol: String) {
        if let range = textField.text?.range(of: decimalSymbol) {
            let index = textField.text?.distance(from: textField.text!.startIndex, to: range.lowerBound) ?? 0
            textField.selectedTextRange = textField.textRange(
                from: textField.beginningOfDocument,
                to: textField.beginningOfDocument
            )
            setCursorPosition(in: textField, offset: index + offset)
        }
    }

    /**
     Retrieves the current cursor position in the given text field.

     - Parameter textField: The text field to handle.

     - Returns: The current cursor position as an integer.
     */
    func getOriginalCursorPosition(in textField: UITextField) -> Int {
        guard let selectedTextRange = textField.selectedTextRange else { return 0 }
        return textField.offset(from: textField.beginningOfDocument, to: selectedTextRange.start)
    }

    /**
     Sets the cursor to a specific position in the given text field.

     - Parameters:
       - textField: The text field to handle.
       - position: The position to set the cursor to.
     */
    func setCursorPosition(in textField: UITextField, to position: UITextPosition?) {
        if let newPosition = position {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }

    /**
     Moves the cursor by a specified offset from its current position in the given text field.

     - Parameters:
       - textField: The text field to handle.
       - offset: The offset to move the cursor by.
     */
    func setCursorPosition(in textField: UITextField, offset: Int) {
        let newPosition = textField.position(
            from: textField.selectedTextRange?.start ?? textField.beginningOfDocument,
            offset: offset
        )
        setCursorPosition(in: textField, to: newPosition)
    }

    /**
     Sets the cursor to its original position after the input state or text has changed in the given text field.
     If the newly added character is a decimal symbol, the cursor is placed after the decimal symbol.

     - Parameters:
       - textField: The text field to handle.
       - cursorOffset: The original cursor offset.
       - oldTextFieldLength: The length of the text field before the change.
     */
    func setCursorOriginalPosition(in textField: UITextField, _ cursorOffset: Int, oldTextFieldLength: Int?) {
        guard let oldLength = oldTextFieldLength,
                let newLength = textField.text?.count,
                oldLength > cursorOffset else {
            return
        }
        let newOffset = newLength - oldLength + cursorOffset
        let newPosition = textField.position(from: textField.beginningOfDocument, offset: newOffset)
        setCursorPosition(in: textField, to: newPosition)
    }

    func isCursorAtEnd(of textField: UITextField) -> Bool {
        guard let selectedRange = textField.selectedTextRange else {
            return false
        }
        return textField.compare(selectedRange.end, to: textField.endOfDocument) == .orderedSame
    }
}
