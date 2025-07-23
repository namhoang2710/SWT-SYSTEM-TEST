//
//  SelectionCard+SetupSlot.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit

extension SelectionCard {
    /// Setup slot by inputted `TymeXSelectionCardSlotOption`
    /// - Parameter option: option of type ``TymeXSelectionCardSlotOption``
    func setupSlot(with option: SelectionCardSlotOption) {
        switch option {
        case .predefined(let predefinedSlot):
            setupPredefinedTopSlot(predefinedSlot)
        case .custom(let uiView):
            setupCustomTopSlot(uiView)
        }
        setupContentByState()
    }

    /// Set up label badge and append to a label
    /// - Parameters:
    ///   - badge: badge text content
    ///   - label: the label that the badge will be appended to
    func setupPredefinedTopSlotLabel(badge: String, label: NSMutableAttributedString) {
        let spacingAttributes: [NSAttributedString.Key: Any] = [.kern: 2]
        let spaceString = NSAttributedString(string: " ", attributes: spacingAttributes)
        label.append(spaceString)
        // adding badge label content
        let badgeAttributes: [NSAttributedString.Key: Any] =
        SmokingCessation.textLabelEmphasizeXs.color(.white)
        let badgeAttachment = TymeXSelectionCardBadgeText(
            text: badge,
            textAttributes: badgeAttributes,
            backgroundColor: SmokingCessation.secondaryColor,
            cornerRadius: 4,
            padding: UIEdgeInsets(top: 0, left: 4, bottom: 2, right: 4)
        )
        let badgeString = NSAttributedString(attachment: badgeAttachment)
        let badgeAttributesWithOffset: [NSAttributedString.Key: Any] = [ .baselineOffset: -2 ]
        let badgeStringWithOffset = NSMutableAttributedString(attachment: badgeAttachment)
        badgeStringWithOffset.addAttributes( badgeAttributesWithOffset,
            range: NSRange(location: 0, length: badgeString.length))
        label.append(badgeStringWithOffset)
    }

    /// Set up predefined slot
    /// - Parameter predefinedSlot: inputted predefined slot
    func setupPredefinedTopSlot(_ predefinedSlot: PredefinedSlot) {
        setupVerticalStackView()
        // create container for title and checkbox
        let titleAndCheckboxContainer = UIView()
        // setup Title Label
        let label = NSMutableAttributedString(
            string: predefinedSlot.title,
            attributes: SmokingCessation.textTitleM
                .color(.black)
                .alignment(.left)
        )
        // adding badge (if there is)
        if let badge = predefinedSlot.badge {
            setupPredefinedTopSlotLabel(badge: badge, label: label)
        }
        titleLabel.attributedText = label
        [titleLabel, checkboxContainerView].forEach { titleAndCheckboxContainer.addSubview($0) }
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleAndCheckboxContainer.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleAndCheckboxContainer.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleAndCheckboxContainer.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: checkboxContainerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: titleAndCheckboxContainer.centerYAnchor),
            checkboxContainerView.trailingAnchor.constraint(equalTo: titleAndCheckboxContainer.trailingAnchor),
            titleAndCheckboxContainer.heightAnchor.constraint(
                greaterThanOrEqualToConstant: ConstantsSelectionCard.titleAndCheckboxContainerHeight
            ),
            predefinedSlot.subTitle1.heightAnchor.constraint(
                greaterThanOrEqualToConstant: ConstantsSelectionCard.iconHeight
            )
        ])
        // setup subtitle 1 & subtitle 2
        if let subTitle2 = predefinedSlot.subTitle2 {
            NSLayoutConstraint.activate([
                subTitle2.heightAnchor.constraint(
                    greaterThanOrEqualToConstant: ConstantsSelectionCard.iconHeight)
            ])
        }
        verticalStackView.addArrangedSubview(titleAndCheckboxContainer)
        predefinedSlot.subTitle1.numberOfLines = 0
        firstSubTitleLabel = predefinedSlot.subTitle1
        verticalStackView.addArrangedSubview(predefinedSlot.subTitle1)
        if let subTitle2 = predefinedSlot.subTitle2 {
            subTitle2.numberOfLines = 0
            secondSubtitleLabel = subTitle2
            verticalStackView.addArrangedSubview(subTitle2)
        }
    }

    /// setting up custom top slot
    /// - Parameter uiView: inputted UIView
    private func setupCustomTopSlot(_ uiView: UIView) {
        customTopSlotView = uiView
        slotContentContainerView.addSubview(uiView)
        uiView.clipsToBounds = true
        uiView.translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = [
            uiView.topAnchor.constraint(equalTo: slotContentContainerView.topAnchor),
            uiView.leadingAnchor.constraint(equalTo: slotContentContainerView.leadingAnchor),
            uiView.trailingAnchor.constraint(equalTo: slotContentContainerView.trailingAnchor)
        ]
        customTopSlotConstraints = constraints
        if model.hasErrorMessage && model.isErrorMessageShown {
                   slotContentContainerView.addSubview(errorStackContainer)
            NSLayoutConstraint.activate([
                errorStackContainer.leadingAnchor.constraint(equalTo: slotContentContainerView.leadingAnchor),
                errorStackContainer.trailingAnchor.constraint(equalTo: slotContentContainerView.trailingAnchor),
                errorStackContainer.bottomAnchor.constraint(equalTo: slotContentContainerView.bottomAnchor),
                errorStackContainer.topAnchor.constraint(equalTo: uiView.bottomAnchor, constant: 4)
            ])
        } else {
            constraints.append(uiView.bottomAnchor.constraint(equalTo: slotContentContainerView.bottomAnchor))
        }
        NSLayoutConstraint.activate(constraints)
    }

    private func setupBottomSlot() {
        guard let bottomSlotView = model.bottomSlotView else { return }
        self.bottomSlotView = bottomSlotView
        addSubview(bottomSlotView)
        bottomSlotView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomSlotView.topAnchor.constraint(equalTo: slotContainerView.bottomAnchor),
            bottomSlotView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSlotView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSlotView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    /// setting up slot content container view
    func setupSlotContentContainerView() {
        slotContainerView.addSubview(slotContentContainerView)
        slotContentContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slotContentContainerView.topAnchor.constraint(
                equalTo: slotContainerView.topAnchor, constant: 16
            ),
            slotContentContainerView.bottomAnchor.constraint(
                equalTo: slotContainerView.bottomAnchor, constant: -16
            ),
            slotContentContainerView.leadingAnchor.constraint(
                equalTo: slotContainerView.leadingAnchor, constant: 16
            ),
            slotContentContainerView.trailingAnchor.constraint(
                equalTo: slotContainerView.trailingAnchor, constant: -16
            )
        ])
    }

    /// setting up slot container view
    func setupSlotContainerView() {
        addSubview(slotContainerView)
        slotContainerView.translatesAutoresizingMaskIntoConstraints = false
        slotContainerView.backgroundColor = .white
        let topAnchorConstraint: NSLayoutConstraint
        if let highlightLabelView = highlightLabelView {
            topAnchorConstraint = slotContainerView.topAnchor.constraint(
                equalTo: highlightLabelView.bottomAnchor,
                constant: -16
            )
        } else {
            topAnchorConstraint = slotContainerView.topAnchor.constraint(equalTo: topAnchor)
        }
        slotContainerView.mxAddTopCorners(radius: 12)
        let selectedColor = model.errorMessage == nil
            ? SmokingCessation.primaryColor.cgColor
        : SmokingCessation.secondaryColor.cgColor
        layer.borderColor = model.cardState == .selected
            ? selectedColor
        : SmokingCessation.secondaryColor.cgColor
        layer.borderWidth = model.cardState == .selected ? 2 : 1
        layer.cornerRadius = 12
        layer.masksToBounds = true
        var constraints: [NSLayoutConstraint] = [
             topAnchorConstraint,
             slotContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
             slotContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)
         ]
        if model.bottomSlotView == nil || (model.cardState == .selected && model.hasErrorMessage) {
            let bottomConstraint = slotContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
            constraints.append(bottomConstraint)
        } else {
            setupBottomSlot()
        }
         NSLayoutConstraint.activate(constraints)
    }
}
