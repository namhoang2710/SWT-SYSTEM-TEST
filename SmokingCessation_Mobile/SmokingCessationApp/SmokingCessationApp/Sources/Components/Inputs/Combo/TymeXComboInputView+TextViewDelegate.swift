//
//  TymeXComboInputView+TextViewDelegate.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 27/02/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXComboInputView {
    public override func textViewDidBeginEditing(_ textView: UITextView) {
        super.textViewDidBeginEditing(textView)
        // hide rightIcon in case empty text
        updateRightButtonState()
    }

    public override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)

        // show/hide rightIcon when there's a changed text
        // Example: text was changed from "t" -> "" that need to hide rightIcon
        updateRightButtonState()
    }

    public override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)

        // update size 24x24 & image for rightIcon as default when losing focus
        updateSizeForRightButton()
        rightButton.setImage(rightIcon, for: .normal)
    }
}
