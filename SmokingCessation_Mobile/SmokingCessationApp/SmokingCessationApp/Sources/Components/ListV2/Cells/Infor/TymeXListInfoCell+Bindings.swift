//
//  TymeXListInfo+Bindings.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 13/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
// swiftlint:disable empty_enum_arguments

import Foundation
import UIKit

extension TymeXListInfoCell {
    public func bind(
        _ model: TymeXListItemModelV2,
        isFirstIndex: Bool = false,
        isLastIndex: Bool = false,
        currentIndex: IndexPath = IndexPath(index: -1)
    ) {
        self.model = model
        self.isFirstIndex = isFirstIndex
        self.isLastIndex = isLastIndex
        self.currentIndex = currentIndex
        self.accessibilityIdentifier = "\(model.listType.getListType())_index_\(currentIndex)"
        updateCellLayouts()
        setupAccessibility()
    }

    func updateCellLayouts() {
        updateLeadingContent()
        updateTrailingContent()
        updateLineView()
        updateLayouts()
        updateMainStacksLayouts()
        configBorders()
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }

    public func updateMainStacksLayouts() {
        // Update max intrinsic widths for leading and trailing content
        maxIntrinsicWidthLeadingContent = max(maxIntrinsicWidthLeadingContent, leadingTitle.intrinsicContentSize.width)

        let trailingContentWidths = [
            trailingTitle.intrinsicContentSize.width,
            trailingSubTitle1.intrinsicContentSize.width,
            trailingSubTitle2.intrinsicContentSize.width
        ]

        maxIntrinsicWidthTrailingContent = trailingContentWidths.max() ?? maxIntrinsicWidthTrailingContent

        let widthContentView: CGFloat = contentView.bounds.width
        let numberOfSpacing = Double(getNumberOfSpacing())
        let width: CGFloat = widthContentView - (spacingItems * numberOfSpacing)

        // limit threadHold for Leading Content with ratio 4/6 & minWidth 120px
        var threadholdLeadingContent = width * 0.4
        threadholdLeadingContent = max(threadholdLeadingContent, 120)
        NSLayoutConstraint.activate([
            stackViewLeadingContent.widthAnchor.constraint(equalToConstant: threadholdLeadingContent)
        ])
    }

    func updateLeadingContent() {
        stackViewLeadingContent.backgroundColor = .clear
        // Title
        if let title = model?.leadingContent?.title {
            let typographyTitle = (model?.leadingContent?.isHighlightTitle ?? false) ?
            SmokingCessation.textTitleS : SmokingCessation.textBodyDefaultM
            leadingTitle.attributedText = NSAttributedString(
                string: title,
                attributes: typographyTitle.color(SmokingCessation.colorTextSubtle)
            )
            leadingTitle.setContentCompressionResistancePriority(.required, for: .vertical)
            stackViewLeadingContent.addArrangedSubview(leadingTitle)
        }
    }

    func updateTrailingContent() {
        guard let trailingContentStatus = model?.trailingContentStatus else { return }
        stackViewTrailingContent.backgroundColor = .clear
        switch trailingContentStatus {
        case .itemContent(let tymeXListItemContent):
            updateTrailingContentWithItem(itemContent: tymeXListItemContent)
        case .amountStatus(_):
            // Do nothing here
            break
        }
    }

    func updateTrailingContentWithItem(itemContent: TymeXTrailingContentItem) {
        // Title
        if let title = itemContent.title {
            let typographyTitle = (itemContent.isHighlightTitle) ?
            SmokingCessation.textTitleS : SmokingCessation.textBodyDefaultM
            trailingTitle.attributedText = NSAttributedString(
                string: title,
                attributes: typographyTitle.color(SmokingCessation.colorTextDefault)
            )
            trailingTitle.setContentCompressionResistancePriority(.required, for: .vertical)
            trailingTitle.setContentCompressionResistancePriority(.required, for: .horizontal)
            stackViewTrailingContent.addArrangedSubview(trailingTitle)
        }

        // SubTitle1
        if let subTitle1 = itemContent.subTitle1 {
            trailingSubTitle1.attributedText = NSAttributedString(
                string: subTitle1,
                attributes: SmokingCessation.textBodyDefaultM.color(SmokingCessation.colorTextSubtle)
            )
            trailingSubTitle1.setContentCompressionResistancePriority(.required, for: .vertical)
            trailingSubTitle1.setContentCompressionResistancePriority(.required, for: .horizontal)
            stackViewTrailingContent.addArrangedSubview(trailingSubTitle1)
        }

        // SubTitle2
        if let subTitle2 = itemContent.subTitle2 {
            trailingSubTitle2.attributedText = NSAttributedString(
                string: subTitle2,
                attributes: SmokingCessation.textBodyDefaultM.color(SmokingCessation.colorTextSubtle)
            )
            trailingSubTitle2.setContentCompressionResistancePriority(.required, for: .vertical)
            trailingSubTitle2.setContentCompressionResistancePriority(.required, for: .horizontal)
            stackViewTrailingContent.addArrangedSubview(trailingSubTitle2)
        }

        // action text
        if let text = itemContent.textAction {
            updateActionText(text)
            stackViewTrailingContent.addArrangedSubview(self.actionText)
        }
    }

    // Set button text
    func updateActionText(_ text: String) {
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: SmokingCessation.textLabelEmphasizeS
                .color(SmokingCessation.colorTextLink)
        )
        actionText.attributedText = attributedString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTextTapped))
        actionText.addGestureRecognizer(tapGesture)
    }

    func configBorders() {
        var maskedCorners: CACornerMask = []
        if isFirstIndex {
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastIndex {
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        if isLastIndex, isFirstIndex {
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                             .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        self.backgroundColor = SmokingCessation.colorBackgroundDefault
        self.clipsToBounds = true
        self.layer.cornerRadius = SmokingCessation.cornerRadius3
        self.layer.maskedCorners = maskedCorners

        self.layer.borderColor = SmokingCessation.colorDividerDividerBase.cgColor
        self.layer.borderWidth = 0
    }

    private func updateLineView() {
        lineView.isHidden = isLastIndex
        lineView.backgroundColor = SmokingCessation.colorDividerDividerBase
    }

    func updateLayouts() {
        // Should call this function to update layout for all subViews with a new Model
        // when having a new content was updated for label's attributedText
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    private func getNumberOfSpacing() -> Int {
        let stackViews = [
            stackViewLeadingContent,
            stackViewTrailingContent
        ]
        var count = 1
        for stackView in stackViews where stackView.bounds.width > 0 {
            count += 1
        }
        return count
    }

    // Action method for button tap
    @objc func actionTextTapped() {
        actionTextCallback?()
    }
}
// swiftlint:enable empty_enum_arguments
