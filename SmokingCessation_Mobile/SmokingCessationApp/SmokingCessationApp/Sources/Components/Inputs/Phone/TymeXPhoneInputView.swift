//
//  TymeXPhoneInputView.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 02/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public class TymeXPhoneInputView: TymeXMaskedInputTextField {
    public lazy var countryCodeView = makeCountryView()
    var flagIcon: UIImage?
    var countryCode: String

    // Closure to handle tap events
    public var onTap: (() -> Void)?

    public init(flagIcon: UIImage?, countryCode: String) {
        self.flagIcon = flagIcon
        self.countryCode = countryCode
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var textAlignment: NSTextAlignment {
        return .left
    }

    override func setupMiddleView() {
        maximumNumberOfLines = 1
        setupRightButton()
        setupTextView()
        setupCountryCode()
        setupPlaceHolderLabel()
    }

    override func animatePlaceholder() {
        let animationConfig = AnimationConfiguration(duration: .duration3, motionEasing: .motionEasingDefault)
        let placeHolderYValue: Double
        if textView.text.isEmpty && !isTyping {
            placeHolderYValue = 0
        } else {
            placeHolderYValue = -placeHolderWhileTypingPosition
        }
        if let placeHolderTopConstraint = placeHolderTopConstraint {
            placeHolderLabel.mxAnimateConstraints(
                constraint: placeHolderTopConstraint, constant: placeHolderYValue, configuration: animationConfig
            )
        }
        updatePlaceHolderWithoutAnimate()
    }

    public override func didTouchOnRightItem() {
        clearText()
    }
}
