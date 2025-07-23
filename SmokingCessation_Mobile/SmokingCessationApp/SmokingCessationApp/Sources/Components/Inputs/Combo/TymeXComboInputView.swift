//
//  TymeXComboInputView.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 27/02/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public class TymeXComboInputView: TymeXInputPickerView {
    public override init(rightIcon: UIImage?) {
        super.init(rightIcon: rightIcon)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func setupView() {
        super.setupView()
        setupNotificationObserver()
        translatesAutoresizingMaskIntoConstraints = false
    }

    override func setupTapView() {
        // do nothing here
    }

    public override func makeTextField() -> UITextView {
        let textView = UITextView()
        textView.autocorrectionType = .no
        textView.textContainerInset = UIEdgeInsets(
            top: SmokingCessation.spacing1, left: 0,
            bottom: SmokingCessation.spacing1, right: 0
        )
        textView.setContentCompressionResistancePriority(.required, for: .horizontal)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.autocapitalizationType = .none
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.contentMode = .scaleToFill
        textView.textContainer.lineBreakMode = .byTruncatingHead
        textView.typingAttributes = SmokingCessation.textLabelEmphasizeL
            .color(inputState.colorInputField)
            .alignment(textAlignment)
        textView.delegate = self
        textView.backgroundColor = .clear
        return textView
    }

    public override func didTouchOnRightItem() {
        if textView.isFirstResponder && !textView.text.isEmpty {
            clearText()

            // set rightIcon as default when text was cleared
            updateRightButtonState()
        } else {
            // moving to focus state when rightButton was pressed
            // textView's tintColor will be re-updated at inputStateChanged()
            textView.becomeFirstResponder()
            textView.tintColor = UIColor.clear

            // callback for tap event
            onViewTapped?()
        }
    }
}
