//
//  OTPTextField.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 23/07/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public class TymeXOTPTextField: UIView {

    private let bottomLine = UIView()
    let label = UILabel()
    private var focusAnimation: CABasicAnimation?
    var onDeleteBackward: ((TymeXOTPTextField) -> Void)?

    enum OTPState {
        case lostFocus, focus, errorLostFocus, errorFocus
    }

    struct Constants {
        static let bottomLineHeight: CGFloat = 1
    }

    var currentState: OTPState = .lostFocus {
        didSet { updateStyleForState() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        setupBottomLine()
        setupLabel()
        updateStyleForState()
    }

    private func setupBottomLine() {
        addSubview(bottomLine)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomLine.heightAnchor.constraint(
                equalToConstant: Constants.bottomLineHeight
            ),
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupLabel() {
        label.textAlignment = .center
        label.attributedText = NSAttributedString(
            string: getText(),
            attributes: SmokingCessation.textLabelEmphasizeL.alignment(.center)
        )
        label.isUserInteractionEnabled = true

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func updateStyleForState() {
        bottomLine.layer.removeAnimation(forKey: TymeXAnimationKey.focusAnimation)
        switch currentState {
        case .lostFocus:
            applyStyle(
                textColor: SmokingCessation.colorTextDefault,
                bottomLineColor: SmokingCessation.colorStrokeSecondaryWeak
            )
        case .focus:
            applyStyle(
                textColor: SmokingCessation.colorTextLink,
                bottomLineColor: SmokingCessation.colorStrokeSecondaryWeak
            )
        case .errorLostFocus, .errorFocus:
            applyStyle(
                textColor: SmokingCessation.colorTextError,
                bottomLineColor: SmokingCessation.colorStrokeErrorBase
            )
        }
        layoutIfNeeded()
    }

    private func applyStyle(textColor: UIColor, bottomLineColor: UIColor) {
        self.bottomLine.backgroundColor = bottomLineColor
        label.attributedText = NSAttributedString(
            string: getText(),
            attributes: SmokingCessation.textLabelEmphasizeL.color(textColor).alignment(.center)
        )
    }

    public func getText() -> String {
        return label.text ?? ""
    }

    public func setText(newText: String) {
        label.text = newText
        updateStyleForState()
    }
}
