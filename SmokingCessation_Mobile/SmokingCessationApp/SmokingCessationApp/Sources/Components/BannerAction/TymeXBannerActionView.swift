//
//  TymeXBannerActionView.swift
//  TymeXUIComponent
//
//  Created by Tung Nguyen on 17/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public class TymeXBannerActionView: TymeXBaseView {
    @IBOutlet weak var leftIconContainerView: UIView!
    @IBOutlet weak var centerContainerView: UIView!
    @IBOutlet weak var bottomButtonContainerView: UIView!
    @IBOutlet weak var rightButtonContainerView: UIView!

    @IBOutlet weak var leftIconImgv: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    // MARK: - IBOutlets
    @IBOutlet weak var paddingTopConstrainst: NSLayoutConstraint!
    @IBOutlet weak var paddingBottomConstrainst: NSLayoutConstraint!
    @IBOutlet weak private(set) var containerView: UIView!
    var titleColor = SmokingCessation.colorTextDefault
    var subTitleColor = SmokingCessation.colorTextSubtle
    var highlightedSubtitleColor = SmokingCessation.colorTextDefault

    // MARK: - Properties

    // MARK: - Public methods
    public func configBanner(
        title: String,
        titleColor: UIColor = SmokingCessation.colorTextDefault,
        subTitle: String? = nil,
        subTitleColor: UIColor = SmokingCessation.colorTextSubtle,
        leftIcon: UIImage? = nil,
        bottomButton: BaseButton? = nil,
        rightButton: UIControl? = nil,
        cornerRadius: CGFloat? = nil,
        borderColor: UIColor? = nil,
        borderWidth: CGFloat? = nil,
        maskedCorners: CACornerMask? = nil,
        highlightedSubtitles: [String]? = nil,
        highlightedSubtitleColor: UIColor = SmokingCessation.colorTextDefault,
        backgroundColor: UIColor = SmokingCessation.colorBackgroundDefault,
        paddingVerticalToContainer: CGFloat = SmokingCessation.spacing4
    ) {
        self.titleColor = titleColor
        self.subTitleColor = subTitleColor
        self.highlightedSubtitleColor = highlightedSubtitleColor
        initTitleLabel(title: title)
        containerView.backgroundColor = backgroundColor
        paddingTopConstrainst.constant = paddingVerticalToContainer
        paddingBottomConstrainst.constant = paddingVerticalToContainer
        if let subtitle = subTitle {
            initSubtitleLabel(subtitle: subtitle, highlightedSubstrings: highlightedSubtitles)
        } else {
            detailLabel.isHidden = true
        }

        if let bottomButton = bottomButton {
            initBottomButton(button: bottomButton)
        } else {
            hideBottom()
        }

        if let rightButton = rightButton {
            initRightButton(button: rightButton)
        } else {
            hideRight()
        }

        if let leftIcon = leftIcon {
            initLeftIcon(image: leftIcon)
        } else {
            hideLeft()
        }

        if let maskedCorners = maskedCorners {
            containerView.clipsToBounds = true
            containerView.layer.cornerRadius = SmokingCessation.cornerRadius3
            containerView.layer.maskedCorners = maskedCorners
            containerView.layer.borderColor = SmokingCessation.colorStrokeInfoStrong.cgColor
            containerView.layer.borderWidth = 1
        }
        if let cornerRadius = cornerRadius {
            self.containerView.clipsToBounds = true
            self.containerView.layer.cornerRadius = cornerRadius
        } else {
            self.containerView.clipsToBounds = true
            self.containerView.layer.cornerRadius = SmokingCessation.cornerRadius3
        }

        if let borderColor = borderColor {
            self.containerView.mxBorderColor = borderColor
            self.containerView.mxBorderWidth = borderWidth ?? 1
        }
    }

    func hideLeft() {
        leftIconContainerView.isHidden = true
    }

    func hideRight() {
        rightButtonContainerView.isHidden = true
    }

    func hideBottom() {
        bottomButtonContainerView.isHidden = true
    }
    // MARK: - Privates

    private func initTitleLabel(title: String) {
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: SmokingCessation.textTitleM.color(titleColor)
                .paragraphStyle(lineSpacing: SmokingCessation.spacing1, alignment: .left)
        )

    }

    private func initSubtitleLabel(subtitle: String, highlightedSubstrings: [String]? = nil) {
        let attributedString = NSMutableAttributedString()
        let attr1 =  NSAttributedString(
            string: subtitle,
            attributes: SmokingCessation.textBodyDefaultM.color(subTitleColor)
                .alignment(.left)
                .lineHeightMultiple(1.2)
        )
        attributedString.append(attr1)
        if let highlightedSubstrings = highlightedSubstrings {
            highlightedSubstrings.forEach {
                let searchedText = $0.lowercased()
                let range: NSRange = attributedString.mutableString.range(of: searchedText, options: .caseInsensitive)

                attributedString.addAttributes(SmokingCessation.textLabelEmphasizeS
                    .color(highlightedSubtitleColor)
                    .alignment(.left)
                    .lineHeightMultiple(1.2), range: range)
            }
        }

        detailLabel.attributedText = attributedString
    }

    private func initLeftIcon(image: UIImage) {
        leftIconImgv.image = image
    }

    private func initBottomButton(button: BaseButton) {
        bottomButtonContainerView.mxRemoveAllSubviews()
        bottomButtonContainerView.addSubview(button)
        let constraints = [
            button.leftAnchor.constraint(equalTo: bottomButtonContainerView.leftAnchor, constant: 0),
            button.bottomAnchor.constraint(equalTo: bottomButtonContainerView.bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func initRightButton(button: UIControl) {
        rightButtonContainerView.mxRemoveAllSubviews()
        rightButtonContainerView.addSubview(button)
        let constraints = [
            button.leftAnchor.constraint(greaterThanOrEqualTo: rightButtonContainerView.leftAnchor, constant: 0),
            button.rightAnchor.constraint(equalTo: rightButtonContainerView.rightAnchor, constant: -SmokingCessation.spacing4),
            button.centerYAnchor.constraint(equalTo: rightButtonContainerView.centerYAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
