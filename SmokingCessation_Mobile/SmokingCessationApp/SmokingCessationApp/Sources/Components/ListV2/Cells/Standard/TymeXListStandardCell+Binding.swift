//
//  TymeXListItemCell+Render.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 06/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
// swiftlint:disable empty_enum_arguments file_length

import Foundation
import UIKit
import Lottie

// MARK: - Binding
extension TymeXListStandardCell {
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
        stackViewMain.alignment = shouldDisplaySingleLine() ? .center : .firstBaseline
        updateCellLayouts()
        setupAccessibility()
    }

    func updateCellLayouts() {
        stackViewMain.mxRemoveAllSubviews()
        updateLeading()
        updateLeadingContent()
        updateTrailingContent()
        updateTrailing()
        updateLineView()
        updateLayouts()
        updateMainStacksLayouts()
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }

    func updateMainStacksLayouts() {
        // Update max intrinsic widths for leading content
        let leadingContentIntrinsicWidths = [
            leadingTitle.textWidth(),
            leadingSubTitle1.textWidth(),
            leadingsubTitle2.textWidth(),
            leadingAddOnStatus.textWidth()
        ]

        maxIntrinsicWidthLeadingContent = leadingContentIntrinsicWidths.max() ?? maxIntrinsicWidthLeadingContent
        // Update max intrinsic widths for trailing content
        let trailingContentIntrinsicWidths = [
            trailingTitle.textWidth(),
            trailingSubTitle1.textWidth(),
            trailingSubTitle2.textWidth(),
            trailingAmount.textWidth()
        ]

        maxIntrinsicWidthTrailingContent = trailingContentIntrinsicWidths.max() ?? maxIntrinsicWidthTrailingContent
        let widthContentView: CGFloat = contentView.bounds.width
        let numberOfSpacing = Double(getNumberOfSpacing())
        let widthLeading = stackViewLeading.frame.width
        let widthTrailing = stackViewTrailing.frame.width
        let width: CGFloat = widthContentView - (widthLeading + widthTrailing + spacingItems * numberOfSpacing)

        // limit threadHold for Trailing Content with maxWidth = 1/2
        let threadholdTrailingContent = width * 0.5
        if widthTrailingContentConstraint == nil {
            widthTrailingContentConstraint = stackViewTrailingContent.widthAnchor.constraint(
                equalToConstant: threadholdTrailingContent
            )
        }

        if maxIntrinsicWidthTrailingContent > threadholdTrailingContent {
            widthTrailingContentConstraint?.constant = threadholdTrailingContent
        } else {
            widthTrailingContentConstraint?.constant = maxIntrinsicWidthTrailingContent
        }
        widthTrailingContentConstraint?.isActive = true
        stackViewTrailingContent.setNeedsLayout()
        stackViewTrailingContent.layoutIfNeeded()
    }
}

// MARK: - Render UI
extension TymeXListStandardCell {
    public func updateLeading() {
        guard let leadingStatus = model?.leadingStatus else { return }
        stackViewLeading.mxRemoveAllSubviews()
        leadingView?.removeFromSuperview()
        leadingView = leadingStatus.getView()
        guard let avatarView = leadingView else { return }
        stackViewMain.addArrangedSubview(stackViewLeading)
        stackViewLeading.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: stackViewLeading.topAnchor, constant: 0),
            avatarView.leftAnchor.constraint(equalTo: stackViewLeading.leftAnchor, constant: 0),
            avatarView.rightAnchor.constraint(equalTo: stackViewLeading.rightAnchor, constant: 0),
            avatarView.bottomAnchor.constraint(equalTo: stackViewLeading.bottomAnchor, constant: 0),
            avatarView.widthAnchor.constraint(equalToConstant: leadingStatus.getWidth()),
            avatarView.heightAnchor.constraint(equalToConstant: leadingStatus.getHeight())
        ])
    }

    func updateLeadingContent() {
        guard let leadingContent = model?.leadingContent else { return }
        stackViewLeadingContent.mxRemoveAllSubviews()
        stackViewMain.addArrangedSubview(stackViewLeadingContent)

        // Title
        if let title = leadingContent.title {
            let typographyTitle = (leadingContent.isHighlightTitle) ?
                SmokingCessation.textTitleM : SmokingCessation.textBodyDefaultL
            leadingTitle.attributedText = NSAttributedString(
                string: title,
                attributes: typographyTitle.color(SmokingCessation.colorTextDefault)
            )
            leadingTitle.setContentCompressionResistancePriority(.required, for: .vertical)
            stackViewLeadingContent.addArrangedSubview(leadingTitle)
        }

        // SubTitle1
        if let subTitle1 = leadingContent.subTitle1 {
            leadingSubTitle1.attributedText = NSAttributedString(
                string: subTitle1,
                attributes: SmokingCessation.textBodyDefaultM.color(SmokingCessation.colorTextSubtle)
            )
            leadingSubTitle1.setContentCompressionResistancePriority(.required, for: .vertical)
            stackViewLeadingContent.addArrangedSubview(leadingSubTitle1)
        }

        // SubTitle2
        if let subTitle2 = leadingContent.subTitle2 {
            leadingsubTitle2.attributedText = NSAttributedString(
                string: subTitle2,
                attributes: SmokingCessation.textBodyDefaultS.color(SmokingCessation.colorTextSubtle)
            )
            leadingsubTitle2.setContentCompressionResistancePriority(.required, for: .vertical)
            stackViewLeadingContent.addArrangedSubview(leadingsubTitle2)
        }

        // Add-on Status
        if let addOnStatus = leadingContent.addOnLabelStatus {
            leadingAddOnStatus.attributedText = NSAttributedString(
                string: addOnStatus.content,
                attributes: SmokingCessation.textTitleS.color(addOnStatus.getColor())
            )
            leadingAddOnStatus.setContentCompressionResistancePriority(.required, for: .vertical)
            stackViewLeadingContent.setContentCompressionResistancePriority(.required, for: .vertical)
            stackViewLeadingContent.addArrangedSubview(leadingAddOnStatus)
        }

        // Add-on Button
        if let addOnButtonStatus = leadingContent.addOnButton {
            leadingAddOnButton = addOnButtonStatus.makeButton()
            leadingAddOnButton?.addTarget(
                self, action: #selector(handleTappedOnLeadingContentButton),
                for: .touchUpInside
            )
            stackViewLeadingContent.addArrangedSubview(leadingAddOnButton!)
        }
    }

    func updateTrailingContent() {
        stackViewTrailingContent.mxRemoveAllSubviews()
        guard let trailingContentStatus = model?.trailingContentStatus else { return }
        stackViewMain.addArrangedSubview(stackViewTrailingContent)
        stackViewTrailingContent.backgroundColor = .clear
        switch trailingContentStatus {
        case .itemContent(let itemContent):
            updateTrailingContentWithItem(itemContent: itemContent)
        case .amountStatus(let amountStatus):
            updateTrailingContentWithAmountStatus(status: amountStatus)
        }
    }

    func updateTrailingContentWithItem(itemContent: TymeXTrailingContentItem) {
        // Title
        if let title = itemContent.title {
            let typographyTitle = (itemContent.isHighlightTitle) ?
            SmokingCessation.textTitleM : SmokingCessation.textBodyDefaultL
            trailingTitle.attributedText = NSAttributedString(
                string: title,
                attributes: typographyTitle.color(SmokingCessation.colorTextDefault)
            )
            stackViewTrailingContent.addArrangedSubview(trailingTitle)

            NSLayoutConstraint.activate([
                trailingTitle.leadingAnchor.constraint(equalTo: stackViewTrailingContent.leadingAnchor, constant: 0),
                trailingTitle.trailingAnchor.constraint(equalTo: stackViewTrailingContent.trailingAnchor, constant: 0)
            ])
        }

        // SubTitle1
        if let subTitle1 = itemContent.subTitle1 {
            trailingSubTitle1.attributedText = NSAttributedString(
                string: subTitle1,
                attributes: SmokingCessation.textBodyDefaultM.color(SmokingCessation.colorTextSubtle)
            )
            stackViewTrailingContent.addArrangedSubview(trailingSubTitle1)
            NSLayoutConstraint.activate([
                trailingSubTitle1.leadingAnchor.constraint(
                    equalTo: stackViewTrailingContent.leadingAnchor, constant: 0),
                trailingSubTitle1.trailingAnchor.constraint(
                    equalTo: stackViewTrailingContent.trailingAnchor, constant: 0)
            ])
        }

        // SubTitle2
        if let subTitle2 = itemContent.subTitle2 {
            trailingSubTitle2.attributedText = NSAttributedString(
                string: subTitle2,
                attributes: SmokingCessation.textBodyDefaultS.color(SmokingCessation.colorTextSubtle)
            )
            stackViewTrailingContent.addArrangedSubview(trailingSubTitle2)

            NSLayoutConstraint.activate([
                trailingSubTitle2.leadingAnchor.constraint(
                    equalTo: stackViewTrailingContent.leadingAnchor, constant: 0),
                trailingSubTitle2.trailingAnchor.constraint(
                    equalTo: stackViewTrailingContent.trailingAnchor, constant: 0)
            ])
        }
    }

    private func updateTrailingContentWithAmountStatus(status: TymeXTrailingContentAmountStatus) {
        // Amount Status

        trailingAmount.attributedText = status.getAttributeString(content: status.content)
        stackViewTrailingContent.addArrangedSubview(trailingAmount)
        NSLayoutConstraint.activate([
            trailingAmount.leadingAnchor.constraint(equalTo: stackViewTrailingContent.leadingAnchor, constant: 0),
            trailingAmount.trailingAnchor.constraint(equalTo: stackViewTrailingContent.trailingAnchor, constant: 0)
        ])
    }

    func updateTrailing() {
        guard let model = self.model else { return }
        guard var trailingStatus = model.trailingStatus else {
            // For Unfavorite action
            if let trailingView = findLottieAnimationView(in: stackViewTrailing) {
                animateScaleDownAndDisappear(view: trailingView)
                stackViewTrailing.isHidden = true
            }
            return
        }
        // Remove all subviews on stackViewTrailing
        stackViewTrailing.mxRemoveAllSubviews()
        stackViewTrailing.isHidden = false

        // Create trailingView from trailingStatus
        trailingView = trailingStatus.getView()
        trailingView?.translatesAutoresizingMaskIntoConstraints = false

        // Actions
        registerTrailingActions()

        // In case there's a trailingView
        if let trailingView = trailingView {
            // Add stackViewTrailing into stackViewMain
            stackViewMain.addArrangedSubview(stackViewTrailing)

            // Establish layout margins for stackViewTrailing
            stackViewTrailing.layoutMargins = UIEdgeInsets(
                top: trailingStatus.getTopSpacingEdgeInset(), left: 0,
                bottom: 0, right: trailingStatus.getRightSpacingEdgeInset()
            )
            stackViewTrailing.isLayoutMarginsRelativeArrangement = true
            switch trailingStatus {
            case .favoriteAnimation(_):
                updateTrailingFavorite()
                playRedHeartAnimation()
            case .checkbox(_), .disclosure, .favorite, .icon(_), .toggle:
                stackViewTrailing.addArrangedSubview(trailingView)
                NSLayoutConstraint.activate([
                    trailingView.leftAnchor.constraint(equalTo: stackViewTrailing.leftAnchor, constant: 0),
                    trailingView.rightAnchor.constraint(equalTo: stackViewTrailing.rightAnchor, constant: 0),
                    trailingView.widthAnchor.constraint(equalToConstant: trailingStatus.getWidth()),
                    trailingView.heightAnchor.constraint(equalToConstant: trailingStatus.getHeight())
                ])
            }
        }
    }

    func registerTrailingActions() {
        guard let model = self.model else { return }
        var trailingStatus: TymeXTrailingStatus?
        if let checkbox = trailingView as? Checkbox {
            checkbox.tapBoxHandler = { isChecked in
                trailingStatus = TymeXTrailingStatus.checkbox(isChecked)
                model.trailingStatus = trailingStatus
                self.onTapTrailingCheckbox?(model, self.currentIndex)
            }
        }
        if let toggle = trailingView as? TymeXToggle {
            toggle.onToggleChanged = { [weak self] isOn in
                guard let self = self else { return }
                trailingStatus = .toggle(isOn)
                model.trailingStatus = trailingStatus
                self.onTapTrailingToggle?(model, self.currentIndex)
            }
        }
        if let imageView = trailingView as? UIImageView {
            // Add tap gesture for icon
            let iconTapGesture = UITapGestureRecognizer(
                target: self, action: #selector(handleTapOnTrailingIcon(_:))
            )
            imageView.addGestureRecognizer(iconTapGesture)
        }
    }

    private func updateTrailingFavorite() {
        if let trailingView = trailingView {
            trailingView.clipsToBounds = false
            stackViewTrailing.addArrangedSubview(trailingView)
            NSLayoutConstraint.activate([
                trailingView.rightAnchor.constraint(equalTo: stackViewTrailing.rightAnchor, constant: 12),
                trailingView.topAnchor.constraint(equalTo: stackViewTrailing.topAnchor, constant: -10),
                trailingView.bottomAnchor.constraint(equalTo: stackViewTrailing.bottomAnchor),
                stackViewTrailing.widthAnchor.constraint(equalToConstant: 10)
            ])
        }
    }

    private func updateLineView() {
        lineView.isHidden = isLastIndex
        lineView.backgroundColor = SmokingCessation.colorDividerDividerBase
    }

    func updateLayouts() {
        // Should call this function to update layout for all subViews with a new Model
        // when having a new content was updated for label's attributedText
        contentView.setNeedsLayout()
    }

    func getNumberOfSpacing() -> Int {
        let stackViews = [
            stackViewLeading, stackViewLeadingContent,
            stackViewTrailingContent, stackViewTrailing
        ]
        var count = 1
        for stackView in stackViews where stackView.bounds.width > 0 {
            count += 1
        }
        return count
    }

    @objc func handleTapOnTrailingIcon(_ sender: UIImageView) {
        guard let model = self.model else { return }
        onTapTrailingIcon?(model, currentIndex)
    }

    func findLottieAnimationView(in view: UIView) -> LottieAnimationView? {
        for subview in view.subviews {
            if let lottieView = subview as? LottieAnimationView {
                return lottieView
            }
            if let lottieView = findLottieAnimationView(in: subview) {
                return lottieView
            }
        }
        return nil
    }

    func shouldDisplaySingleLine() -> Bool {
        return model?.isSingleLineType ?? false
    }

    func isSingleLineLeadingContent() -> Bool {
        let isTitleEmpty = model?.leadingContent?.title?.isEmpty ?? true
        let isSubTitle1Empty = model?.leadingContent?.subTitle1?.isEmpty ?? true
        let isSubTitle2Empty = model?.leadingContent?.subTitle2?.isEmpty ?? true
        let isAddOnLabelStatusEmpty = model?.leadingContent?.addOnLabelStatus == nil
        let isAddOnButtonEmpty = model?.leadingContent?.addOnButton == nil

        // Count the number of non-empty elements
        let nonEmptyCount = [
            isTitleEmpty, isSubTitle1Empty,
            isSubTitle2Empty, isAddOnLabelStatusEmpty,
            isAddOnButtonEmpty
        ].filter { !$0 }.count

        // Return true if exactly one element is non-empty
        return nonEmptyCount == 1
    }

    func isSingleLineTrailingContent() -> Bool {
        // return true if trailingContentStatus is nil
        guard let trailingContentStatus = model?.trailingContentStatus else { return true }
        switch trailingContentStatus {
        case .itemContent(let itemContent):
            return checkSingleLineWithContent(itemContent: itemContent)
        case .amountStatus(_):
            return true
        }
    }

    func checkSingleLineWithContent(itemContent: TymeXTrailingContentItem) -> Bool {
        let isTitleEmpty = itemContent.title?.isEmpty ?? true
        let isSubTitle1Empty = itemContent.subTitle1?.isEmpty ?? true
        let isSubTitle2Empty = itemContent.subTitle2?.isEmpty ?? true

        // Count the number of non-empty elements
        let nonEmptyCount = [
            isTitleEmpty, isSubTitle1Empty, isSubTitle2Empty
        ].filter { !$0 }.count

        // Return true if exactly one element is non-empty
        return nonEmptyCount == 1
    }
}
// swiftlint:enable empty_enum_arguments file_length
