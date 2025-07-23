//
//  TymeXMaskedInputTextField.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 04/09/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class TymeXMaskedInputTextField: TymeXInputTextField {
    private let maskCharacter: Character = "#"
    public var inputMask: String = ""

    public func setupConfig(
        placeHolder: String,
        numberOfLines: Int = 1,
        titleStr: String? = nil,
        defaultMessage: String? = nil,
        regex: String? = "[^0-9a-zA-Z]",
        inputMask: String = "###-###-###-###"
    ) {
        super.updateConfigTextField(
            placeHolder: placeHolder,
            numberOfLines: numberOfLines,
            titleStr: titleStr,
            defaultMessage: TymeXInputHelperMessage(content: .text(defaultMessage)),
            filteringRegexFormat: regex
        )
        self.inputMask = inputMask
    }

    // Format input value by removing illegal characters with regex
    override func formatInputValue(input: String?) -> String {
        guard let input = input else { return "" }
        return input.replacingOccurrences(of: filteringRegex ?? "", with: "", options: .regularExpression)
    }

    // Process text changed in textview
    public override func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        var adjustedRange = range
        print(" === text = \(text) ==== ")
        guard let swiftRange = Range(range), text.isEmpty, range.length == 1 else {
            // For add new a character
            return super.textView(textView, shouldChangeTextIn: range, replacementText: text)
        }

        // For delete a character
        let deletedText = textInputed[swiftRange]
        print(" === textToChange = \(deletedText) ==== ")

        // If deletedText is NOT Number/Alphabet/maskCharacter
        if !deletedText.isNumber, !deletedText.isAlphabetCharacters(), deletedText != String(maskCharacter) {
            adjustedRange = NSRange(location: range.location - 1, length: range.length + 1)
        }

        return super.textView(textView, shouldChangeTextIn: adjustedRange, replacementText: text)
    }

    // Calculate the difference Before apply mask
    private func calculateDifferenceBefore(range: UITextRange?) -> Int {
        guard let range = range else { return 0 }
        let text = textView.text(in: range) ?? ""
        return formatInputValue(input: text).count - text.count
    }

    // Calculate the difference After apply mask
    private func calculateDifferenceAfter(range: UITextRange?, atPosition pos: UITextPosition?) -> Int {
        guard let range = range else { return 0 }
        let text = textView.text(in: range) ?? ""
        let difference = formatInputValue(input: text).count - text.count

        guard
            let pos = pos,
            let newPos = textView.position(from: pos, offset: -difference),
            let newRange = textView.textRange(from: textView.beginningOfDocument, to: newPos)
        else {
            return difference
        }

        let newText = textView.text(in: newRange) ?? ""
        return formatInputValue(input: newText).count - newText.count
    }

    // Apply mask for text and update cursor's position
    private func applyMaskToText() {
        let pos = textView.selectedTextRange?.start
        let range = textView.textRange(from: textView.beginningOfDocument, to: pos ?? textView.endOfDocument)
        let diffBefore = calculateDifferenceBefore(range: range)
        textView.text = applyMask(textView.text, with: inputMask)
        let diffAfter = calculateDifferenceAfter(range: range, atPosition: pos)

        if let oldPos = pos,
           let newPosition = textView.position(from: oldPos, offset: diffBefore - diffAfter),
           let newRange = textView.textRange(from: newPosition, to: newPosition) {
            DispatchQueue.main.async { [weak self] in
                self?.textView.selectedTextRange = newRange
            }
        }
    }

    public override func textViewDidChange(_ textView: UITextView) {
        applyMaskToText()
        super.textViewDidChange(textView)
    }

    // Apply mask for text
    private func applyMask(_ text: String, with mask: String) -> String {
        var filteredText = text.replacingOccurrences(of: filteringRegex ?? "", with: "", options: .regularExpression)
        var result = ""

        for maskCharacter in mask {
            guard !filteredText.isEmpty else { break }
            if maskCharacter == self.maskCharacter {
                result.append(filteredText.removeFirst())
            } else {
                result.append(maskCharacter)
            }
        }
        return result.isEmpty ? filteredText : result
    }
}
