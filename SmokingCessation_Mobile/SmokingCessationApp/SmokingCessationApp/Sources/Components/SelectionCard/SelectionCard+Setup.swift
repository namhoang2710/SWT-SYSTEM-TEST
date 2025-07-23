//
//  SelectionCard+Setup.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit

extension SelectionCard {
    // MARK: - Functions
    func setupUI() {
        setupHighLightLabel()
        setupSlotContainerView()
        setupSlotContentContainerView()
        configure(with: model)
    }

    /// Set up predefined slot
    /// - Parameter predefinedSlot: inputted predefined slot
    func setupVerticalStackView() {
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 4
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        slotContentContainerView.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: slotContentContainerView.topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: slotContentContainerView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: slotContentContainerView.trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: slotContentContainerView.bottomAnchor)
        ])
    }

    /// Setting up highlight label
    func setupHighLightLabel() {
        guard model.highlightLabel != nil else { return }
        if model.hasErrorMessage {
            highlightLabelView?.removeFromSuperview()
            highlightLabelView = nil
            return
        }
        let labelView = SelectionCardHighlightLabel(selectionCardModel: model)
        addSubview(labelView)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        highlightLabelView = labelView
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: topAnchor),
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - Checkbox and error icon
    /// Function to set up checkbox or error icon and their container
    private func setupCheckboxContainerView() {
        checkboxContainerView.translatesAutoresizingMaskIntoConstraints = false
        if case .custom = model.topSlotOption {
            slotContentContainerView.addSubview(checkboxContainerView)
            NSLayoutConstraint.activate([
                checkboxContainerView.topAnchor.constraint(equalTo: slotContentContainerView.topAnchor),
                checkboxContainerView.trailingAnchor.constraint(equalTo: slotContentContainerView.trailingAnchor),
                checkboxContainerView.widthAnchor.constraint(equalToConstant: 32),
                checkboxContainerView.heightAnchor.constraint(
                    equalToConstant: ConstantsSelectionCard.itemContainerHeight
                )
            ])
            bringSubviewToFront(checkboxContainerView)
        } else {
            NSLayoutConstraint.activate([
                checkboxContainerView.widthAnchor.constraint(equalToConstant: 32),
                checkboxContainerView.heightAnchor.constraint(
                    equalToConstant: ConstantsSelectionCard.itemContainerHeight
                )
            ])
        }
    }

    private func setupCheckbox() {
        let checkbox = Checkbox(configuration: .init(title: ""))
        checkbox.isChecked = model.cardState == .selected
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.tapBoxHandler = { [weak self] isChecked in
            self?.handleCheckboxToggle(isChecked: isChecked)
        }
        checkbox.isUserInteractionEnabled = false
        checkbox.accessibilityIdentifier = "checkBox\(type(of: self))"
        checkboxContainerView.addSubview(checkbox)
        NSLayoutConstraint.activate([
            checkbox.trailingAnchor.constraint(equalTo: checkboxContainerView.trailingAnchor)
        ])
    }

    /// Function to set up the content when in error state
    /// - Parameter errorMessage: the error message showed in error stack view
    private func setupErrorState(errorMessage: String) {
        let imageView = UIImageView(image: SmokingCessation().iconError)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "iconError\(type(of: self))"
        checkboxContainerView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: checkboxContainerView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: ConstantsSelectionCard.itemContainerHeight),
                 imageView.widthAnchor.constraint(equalToConstant: ConstantsSelectionCard.itemContainerHeight)
        ])
        if model.isErrorMessageShown {
            setupErrorStack(errorMessage: errorMessage)
        }
    }

    /// Function to set up the error stack view
    /// - Parameter errorMessage: the error message content
    private func setupErrorStack(errorMessage: String) {
        if case .predefined = model.topSlotOption {
            verticalStackView.addArrangedSubview(errorStackContainer)
        }
        errorStackContainer.translatesAutoresizingMaskIntoConstraints = false
        errorStackContainer.addSubview(errorStackView)
        errorStackView.translatesAutoresizingMaskIntoConstraints = false
        if let errorIcon = errorStackView.arrangedSubviews.first(where: { $0 is UIImageView }) as? UIImageView {
             NSLayoutConstraint.activate([
                errorIcon.widthAnchor.constraint(equalToConstant: ConstantsSelectionCard.iconHeight),
                 errorIcon.heightAnchor.constraint(equalToConstant: ConstantsSelectionCard.iconHeight)
             ])
         }
        errorStackView.showErrorMessage(errorMessage)
        NSLayoutConstraint.activate([
            errorStackView.leadingAnchor.constraint(equalTo: errorStackContainer.leadingAnchor),
            errorStackView.topAnchor.constraint(equalTo: errorStackContainer.topAnchor),
            errorStackView.bottomAnchor.constraint(equalTo: errorStackContainer.bottomAnchor),
            errorStackView.trailingAnchor.constraint(equalTo: errorStackContainer.trailingAnchor)
        ])
    }

    /// Set up content based on different states
    func setupContentByState() {
        setupCheckboxContainerView()
        if let errorMessage = model.errorMessage {
            setupErrorState(errorMessage: errorMessage)
        } else {
            setupCheckbox()
        }
    }

    /// Function to handle switching state when checkbox is checked
    /// - Parameter isChecked: A boolean depicts whether the checkbox is ticked
    func handleCheckboxToggle(isChecked: Bool) {
        model.cardState = isChecked ? .selected : .normal
    }
}

