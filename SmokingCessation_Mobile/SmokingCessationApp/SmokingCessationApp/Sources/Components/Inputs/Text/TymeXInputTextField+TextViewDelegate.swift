//
//  TymeXInputTextField+TextViewDelegate.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 05/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UITextViewDelegate
extension TymeXInputTextField: UITextViewDelegate {
    public func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        if text == "\n" && returnKeyType != .default {
            onShouldReturn?()
            return false
        }

        let formattedInput = formatInputValue(input: text)
        let currentText = textView.text as NSString
        let modifiedTextView = currentText.replacingCharacters(in: range, with: formattedInput)
        if let maxLength = self.limitCharacter, modifiedTextView.count > maxLength {
            // Calculate the number of characters that can be added
            let allowedLength = maxLength - currentText.length + range.length
            if allowedLength > 0 {
                // Append only the allowed number of characters
                let allowedText = (formattedInput as NSString).substring(to: allowedLength)
                replaceInputValue(range, allowedText)
                updateHelperMessage(text: currentText.replacingCharacters(in: range, with: allowedText))

                // Move the cursor to the end of the allowed text
                DispatchQueue.main.async {
                    let newCursorPosition = range.location + allowedText.count
                    textView.selectedRange = NSRange(location: newCursorPosition, length: 0)
                }
            }
            TymeXHapticFeedback.light.vibrate()
            mxShake()
            return false
        }

        replaceInputValue(range, formattedInput)
        updateHelperMessage(text: modifiedTextView)
        return false
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        if inputState != .error || textView.text.isEmpty {
            inputState = .focus
        } else if inputState == .error {
            rightButton.isHidden = false
            animatePlaceholder()
        } else {
            rightButton.isHidden = false
        }
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        if inputState != .error || textView.text.isEmpty {
            inputState = .loseFocus
        } else if inputState == .error {
            updateTextField(content: textView.text)
            animatePlaceholder()
        } else {
            updateTextField(content: textView.text)
        }
        onEndEdited?(textView.text)
    }

    public func textViewDidChange(_ textView: UITextView) {
        // Because textViewDidBeginEditing, we ignore input state is error
        // We shouldn't remove this statement, because the inputStateChanged() executed too many times
        // Reproduce: executing fillInputText() at viewWillAppear()
        if inputState == .error {
            inputState = .focus
        } else {
            updateContentViews()
        }
        onTextViewDidChange?(textView.text)
    }
}
