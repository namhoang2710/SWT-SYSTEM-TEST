//
//  TymeXInputPickerView.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 31/07/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class TymeXInputPickerView: TymeXInputTextField {
    public var onViewTapped: TymeXCompletion?
    var rightIcon: UIImage?
    private let tapView = UIView()

    public init(rightIcon: UIImage?) {
        self.rightIcon = rightIcon
        super.init(frame: .zero)
        setupTapView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func setupView() {
        super.setupView()
        setupTapView()
        setupNotificationObserver()
        translatesAutoresizingMaskIntoConstraints = false
    }

    func setupTapView() {
        tapView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tapView)

        NSLayoutConstraint.activate([
            tapView.topAnchor.constraint(equalTo: self.topAnchor),
            tapView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tapView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tapView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapView.addGestureRecognizer(tapGesture)

        bringSubviewToFront(tapView)
    }

    public override func makeRightButton() -> UIButton {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(rightIcon, for: .normal)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(didTouchOnRightItem), for: .touchUpInside)
        button.isHidden = false
        return button
    }

    public override func makeTextField() -> UITextView {
        let field = NoCursorTextView()
        _ = field.layoutManager

        field.autocorrectionType = .no
        field.textContainerInset = UIEdgeInsets(top: SmokingCessation.spacing1, left: 0, bottom: SmokingCessation.spacing1, right: 0)
        field.setContentCompressionResistancePriority(.required, for: .horizontal)
        field.setContentCompressionResistancePriority(.required, for: .vertical)
        field.autocapitalizationType = .none
        field.showsHorizontalScrollIndicator = false
        field.showsVerticalScrollIndicator = false
        field.isScrollEnabled = false
        field.contentMode = .scaleToFill
        field.textContainer.lineBreakMode = .byTruncatingHead
        field.typingAttributes = SmokingCessation.textLabelEmphasizeL.color(inputState.colorInputField).alignment(.center)
        field.delegate = self
        field.backgroundColor = .clear
        return field
    }

    // No need to use underLineAnimator to run animation when changing states
    override func startAnimation(isFocus: Bool) {
        updateUnderLineWithoutAnimation()
    }

    // Only shake textView for error case
    override func errorAnimation() {
        textView.mxShake()
    }

    public override func updateTextField(content: String) {
        // check limited character before update it into textView
        var newText = content
        if let maxLength = self.limitCharacter, newText.count > maxLength {
            newText = String(newText.prefix(maxLength))
        }
        if !newText.isEmpty && newText != textView.text {

            // Set textView at start point (below bottom)
            textView.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)

            // Update content for textView
            textView.attributedText = NSAttributedString(
                string: newText,
                attributes: SmokingCessation.textLabelEmphasizeL
                    .color(inputState.colorInputField)
                    .alignment(.center)
            )

            // Animation to display textView from bottomLine with alpha value
            self.textView.alpha = 0
            UIView.animate(withDuration: AnimationDuration.duration3.value, delay: 0.2, animations: {
                self.textView.alpha = 1
            })

            // Animation to move textview's position
            let configuration = AnimationConfiguration(
                duration: .duration4,
                delay: .undefined,
                motionEasing: .motionEasingDefault
            )
            UIView.mxCubicAnimateBy(configuration, animations: { [weak self] in
                guard let self = self else { return }
                self.textView.transform = .identity
            })
            // Animation for placeHolder
            self.animatePlaceholder()
        } else {
            textView.attributedText = NSAttributedString(
                string: newText,
                attributes: SmokingCessation.textLabelEmphasizeL
                    .color(inputState.colorInputField)
                    .alignment(.center)
            )
        }
    }

    public override func getRightButtonSize() -> CGSize {
        return CGSize(width: 24, height: 24)
    }

    public override func didTouchOnRightItem() {
        handleTapGesture()
    }

    @objc private func handleTapGesture() {
        textView.becomeFirstResponder()
        onViewTapped?()
    }

    func setupNotificationObserver() {
        let notificationName = Notification.Name("TymeXActionModalPresentationController")
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleDismissActionModal),
            name: notificationName, object: nil
        )
    }

    @objc private func handleDismissActionModal() {
        self.textView.resignFirstResponder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

class NoCursorTextView: UITextView {
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
}
