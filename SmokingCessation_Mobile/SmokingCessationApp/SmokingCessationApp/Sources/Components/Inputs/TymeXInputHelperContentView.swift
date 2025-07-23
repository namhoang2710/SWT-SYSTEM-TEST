//
//  TymeXInputHelperContentView.swift
//  TymeComponent
//
//  Created by Tuan Tran on 15/04/2022.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public enum HelperStyle {
    case error(_ msg: String)
    case warning(_ msg: String)
    case center(_ msg: String)
    case leftRight(leftStr: String, rightStr: String)
}

open class TymeXInputHelperContentView: UIView {
    private lazy var stackViewMessage = makeStackViewMessage()
    private lazy var errorIcon = makeErrorIcon()
    private(set) lazy var messageLabel = makeMessageLabel()
    private(set) lazy var otherLabel = makeOtherLabel()
    private let errorIconSize: CGSize = CGSize(width: 16.0, height: 16.0)

    // MARK: Properties
    private var isStackViewFullSize: Bool = false {
        didSet {
            leadingStackView?.isActive = isStackViewFullSize
            greaterLeadingStackView?.isActive = !isStackViewFullSize
        }
    }

    private var leadingStackView: NSLayoutConstraint?
    private var greaterLeadingStackView: NSLayoutConstraint?

    // MARK: Setup Views
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupAccessibility()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        setupAccessibility()
    }

    public func updateContentView(_ style: HelperStyle) {
        switch style {
        case .center(let str):
            isStackViewFullSize = false
            stackViewMessage.arrangedSubviews.forEach { subView in
                if subView != messageLabel {
                    subView.removeFromSuperview()
                    stackViewMessage.removeArrangedSubview(subView)
                }
            }
            messageLabel.attributedText = NSAttributedString(
                string: str,
                attributes: SmokingCessation.textLabelDefaultS
                    .color(SmokingCessation.colorTextSubtle)
                    .paragraphStyle(lineSpacing: SmokingCessation.spacing2, alignment: .center)
            )
        case .error(let str):
            isStackViewFullSize = false
            stackViewMessage.mxInsertToArrangedSubviews(errorIcon, atIndex: 0)
            stackViewMessage.arrangedSubviews.forEach { subView in
                if subView != messageLabel && subView != errorIcon {
                    subView.removeFromSuperview()
                    stackViewMessage.removeArrangedSubview(subView)
                }
            }
            messageLabel.attributedText = NSAttributedString(
                string: str,
                attributes: SmokingCessation.textLabelDefaultS
                    .color(SmokingCessation.colorTextError)
                    .paragraphStyle(lineSpacing: SmokingCessation.spacing2, alignment: .center)
            )
        case .warning(let str):
            isStackViewFullSize = false
            stackViewMessage.mxInsertToArrangedSubviews(errorIcon, atIndex: 0)
            stackViewMessage.arrangedSubviews.forEach { subView in
                if subView != messageLabel && subView != errorIcon {
                    subView.removeFromSuperview()
                    stackViewMessage.removeArrangedSubview(subView)
                }
            }
            messageLabel.attributedText = NSAttributedString(
                string: str,
                attributes: SmokingCessation.textLabelDefaultS
                    .paragraphStyle(lineSpacing: SmokingCessation.spacing2, alignment: .center)

            )
        case .leftRight(let leftStr, let rightStr):
            updateContentViewForStyleLeftRight(leftStr: leftStr, rightStr: rightStr)
        }
        layoutIfNeeded()
    }

    public func setupAccessibility() {
        messageLabel.accessibilityIdentifier = "messageLabel\(type(of: self))"
        otherLabel.accessibilityIdentifier = "otherLabel\(type(of: self))"
        errorIcon.accessibilityIdentifier = "errorIcon\(type(of: self))"
    }
}

// MARK: Privates

extension TymeXInputHelperContentView {
    private func makeStackViewMessage() -> UIStackView {
        let stackViewMessage = UIStackView(arrangedSubviews: [messageLabel])
        stackViewMessage.axis = .horizontal
        stackViewMessage.alignment = .top
        stackViewMessage.distribution = .fill
        stackViewMessage.spacing = SmokingCessation.spacing1
        return stackViewMessage
    }

    private func makeErrorIcon() -> UIImageView {
        let imageView = UIImageView(
            image: SmokingCessation().iconError?.withRenderingMode(.alwaysTemplate)
        )
        imageView.tintColor = SmokingCessation.colorIconDefaultExtra
        imageView.mxAnchor(size: errorIconSize)
        return imageView
    }

    private func makeMessageLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    private func makeOtherLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(UILayoutPriority(901), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(901), for: .horizontal)
        return label
    }

    private func updateContentViewForStyleLeftRight(leftStr: String, rightStr: String) {
        isStackViewFullSize = true
        stackViewMessage.mxInsertToArrangedSubviews(otherLabel)
        stackViewMessage.arrangedSubviews.forEach { subView in
            if subView != messageLabel && subView != otherLabel {
                subView.removeFromSuperview()
                stackViewMessage.removeArrangedSubview(subView)
            }
        }
        messageLabel.attributedText = NSAttributedString(
            string: leftStr,
            attributes: SmokingCessation.textLabelDefaultS
        )
        otherLabel.attributedText = NSAttributedString(
            string: rightStr,
            attributes: SmokingCessation.textLabelDefaultS
        )
    }

    private func setupView() {
        self.backgroundColor = .clear
        addSubview(stackViewMessage)

        stackViewMessage.mxAnchorCenter(xAxis: centerXAnchor)
        stackViewMessage.mxAnchor(
            top: topAnchor,
            bottom: bottomAnchor,
            padding: UIEdgeInsets(top: 2.0, left: 0.0, bottom: 0.0, right: 0.0)
        )

        leadingStackView = stackViewMessage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        greaterLeadingStackView = stackViewMessage.leadingAnchor
            .constraint(greaterThanOrEqualTo: leadingAnchor, constant: 0)

        leadingStackView?.isActive = isStackViewFullSize
        greaterLeadingStackView?.isActive = !isStackViewFullSize
    }
}

extension UIStackView {
    func mxInsertToArrangedSubviews(_ view: UIView, atIndex: Int? = nil) {
        guard !self.arrangedSubviews.contains(view) else { return }
        self.insertArrangedSubview(view, at: atIndex ?? self.arrangedSubviews.endIndex)
    }
}
