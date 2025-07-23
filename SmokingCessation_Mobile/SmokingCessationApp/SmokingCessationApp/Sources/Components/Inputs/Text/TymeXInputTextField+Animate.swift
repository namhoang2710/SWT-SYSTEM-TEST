//
//  TymeXInputTextField+Animate.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 05/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation

extension TymeXInputTextField {
    @objc func animatePlaceholder() {
        let animationConfig = AnimationConfiguration(duration: .duration3, motionEasing: .motionEasingDefault)
        let placeHolderYValue: Double
        var scale = 1.0
        if textView.text.isEmpty && !isTyping {
            placeHolderYValue = 0
            scale = 12/20
        } else {
            placeHolderYValue = -placeHolderWhileTypingPosition
            scale = 20/12
        }
        if let placeHolderTopConstraint = placeHolderTopConstraint {
            placeHolderLabel.mxAnimateConstraints(
                constraint: placeHolderTopConstraint, constant: placeHolderYValue, configuration: animationConfig
            )
        }
        let toAttrs = getPlaceHolderAttributedString(placeHolderString, isEmptyText: textView.text.isEmpty)
        let fromAttrs = placeHolderLabel.attributedText ?? toAttrs
        let alreadyAnimated = placeHolderLabel.layer.animationKeys()?.isEmpty ?? true
        if textView.text.isEmpty && !alreadyAnimated {
            placeHolderLabel.mxAnimateScaleAndUpdateAttributes(
                fromAttrs: fromAttrs,
                toAttrs: toAttrs,
                scaleRatio: scale,
                duration: AnimationDuration.duration3.value,
                animateAnchorPoint: LabelAnimateAnchorPoint.centerXCenterY)
        } else {
            updatePlaceHolderWithoutAnimate()
        }
    }

    public func updatePlaceHolderWithoutAnimate() {
        placeHolderLabel.attributedText = getPlaceHolderAttributedString(
            placeHolderString,
            isEmptyText: textView.text.isEmpty,
            isFocus: textView.isFirstResponder
        )
    }
}
