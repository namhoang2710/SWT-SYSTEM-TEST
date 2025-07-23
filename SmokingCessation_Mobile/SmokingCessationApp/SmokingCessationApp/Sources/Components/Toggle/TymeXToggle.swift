//
//  TymeXToggle.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 22/02/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import UIKit

open class TymeXToggle: UIView {
    let toggleCircle = UIView()
    var isOn = false
    var activeColor: UIColor?
    var inactiveColor: UIColor?
    var thumbColor: UIColor?
    var defaultWidth: CGFloat = 0
    var defaultHeight: CGFloat = 0
    var accessibilityID: String?

    // Callback closure
    public var onToggleChanged: ((Bool) -> Void)?

    // Constraints for toggleCircle
    var toggleCircleLeadingConstraint: NSLayoutConstraint!

    // Custom initializer
    public init(
        activeColor: UIColor? = SmokingCessation.colorBackgroundSelectBase,
        inactiveColor: UIColor? = SmokingCessation.colorBackgroundSecondaryLight,
        thumbColor: UIColor? = SmokingCessation.colorBackgroundDefault,
        width: CGFloat? = 40.0, height: CGFloat? = 24.0,
        initialState: Bool = false,
        accessibilityID: String? = nil
    ) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.thumbColor = thumbColor
        self.defaultWidth = width ?? 0
        self.defaultHeight = height ?? 0
        self.isOn = initialState
        self.accessibilityID = accessibilityID
        super.init(frame: .zero)
        setupView()
        setupAccessibility()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been supported anymore.")
    }

    @objc func toggleTapped() {
        isOn.toggle()
        animateToggle()
        onToggleChanged?(isOn)
        TymeXHapticFeedback.medium.vibrate()
    }

    func animateToggle() {
        let timingParameters = UICubicTimingParameters(
            controlPoint1: CGPoint(x: 0.6, y: 0.0),
            controlPoint2: CGPoint(x: 0.4, y: 0.0)
        )
        let animator = UIViewPropertyAnimator(duration: 0.3, timingParameters: timingParameters)
        animator.addAnimations {
            self.updateToggleAppearance()
        }
        animator.startAnimation()
    }

    func updateToggleAppearance() {
        if self.isOn {
            self.toggleCircleLeadingConstraint.constant = self.frame.width - self.toggleCircle.frame.width - 2
            self.backgroundColor = self.activeColor
        } else {
            self.toggleCircleLeadingConstraint.constant = 2
            self.backgroundColor = self.inactiveColor
        }
        self.layoutIfNeeded()
    }
}
