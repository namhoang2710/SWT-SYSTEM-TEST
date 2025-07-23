//
//  ButtonDock+Setup.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

extension ButtonDock {
    func setupView() {
        setupContainerView()
        setupMainStackView()
        setupLineView()
        setupBackgroundColor()
        setupMainFeeStackView()
        setupTermStackView()
        setupErrorMessage()
        setupButtons()
        setupHelperMessage()
        setupSlot()
        registerKeyboard()
        self.layoutIfNeeded()
    }

    func setupLineView() {
        addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: topAnchor),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        if displayMode != .none {
            lineView.isHidden = (displayMode != .alwayShowSeperator)
        } else {
            lineView.isHidden = !needShowLineView
        }
    }

    func setupBackgroundColor() {
        self.backgroundColor = self.bgColor
    }

    func setupContainerView() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = containerView.topAnchor.constraint(equalTo: topAnchor, constant: 16)
        topConstraint.priority = UILayoutPriority(750)
        NSLayoutConstraint.activate([
            topConstraint,
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: UIDevice.current.hasHomeIndicator ? 0 : -16
        )
        containerViewBottomConstraint.isActive = true
    }

    func setupMainStackView() {
        containerView.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    func setupMainFeeStackView() {
        guard case TermsFeeStatus.fee(let models) = termsFeeStatus else { return }

        feeFooterModels = models
        models.forEach { model in
            if let stackView = createFeeStackViewAndAddToMainFeeStackView(for: model) {
                mainFeeStackView.addArrangedSubview(stackView)
            }
        }
        mainStackView.addArrangedSubview(mainFeeStackView)
    }

    func createFeeStackViewAndAddToMainFeeStackView(for model: FeeModel) -> UIStackView? {
        switch model.type {
        case .additionalFee:
            stackViewAdditionalFee = ButtonDock.createFeeStackView(model: model)
            return stackViewAdditionalFee?.0
        case .fee:
            stackViewFee = ButtonDock.createFeeStackView(model: model)
            return stackViewFee?.0
        case .amountAfterFee:
            stackViewAmountAfterFee = ButtonDock.createFeeStackView(model: model)
            return stackViewAmountAfterFee?.0
        case .none:
            return nil
        }
    }

    func setupTermStackView() {
        if case TermsFeeStatus.terms(let text, let needShowCheckBox) = termsFeeStatus {
            // termLabel
            var typography = SmokingCessation.textLabelDefaultS
                .color(.gray)
                .alignment(.left)

            // emptyView & checkbox
            let emptyView = UIView()
            termStackView.addArrangedSubview(termLabel)
            if needShowCheckBox {
                termStackView.addArrangedSubview(emptyView)
                termStackView.addArrangedSubview(checkbox)
            } else {
                typography = SmokingCessation.textLabelDefaultS
                    .color(.gray).alignment(.center)
            }
            let attributeText = NSAttributedString(string: text, attributes: typography)
            termLabel.attributedText = attributeText
            mainStackView.addArrangedSubview(termStackView)
        }
    }

    func setupButtons() {
        for button in buttons {
            mainStackView.addArrangedSubview(button)
        }
    }

    func setupErrorMessage() {
        mainStackView.addArrangedSubview(errorContainer)
        errorContainer.addSubview(errorStackView)
        NSLayoutConstraint.activate([
            errorStackView.topAnchor.constraint(equalTo: errorContainer.topAnchor),
            errorStackView.bottomAnchor.constraint(equalTo: errorContainer.bottomAnchor),
            errorStackView.trailingAnchor.constraint(lessThanOrEqualTo: errorContainer.trailingAnchor, constant: 0),
            errorStackView.centerXAnchor.constraint(equalTo: errorContainer.centerXAnchor)
        ])
        errorContainer.isHidden = true
    }

    func setupHelperMessage() {
        if !helperMessage.isEmpty {
            helperLabel.attributedText = NSAttributedString(
                string: helperMessage,
                attributes: SmokingCessation.textLabelDefaultXs
                    .color(.gray)
                    .paragraphStyle(lineSpacing: 8, alignment: .center)
            )
            mainStackView.addArrangedSubview(helperLabel)
        }
    }

    func setupSlot() {
        if let slot = self.slotView {
            mainStackView.addArrangedSubview(slot)
        }
    }
}

