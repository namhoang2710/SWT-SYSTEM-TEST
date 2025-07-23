//
//  TymeXSelectionCardHighlightLabel.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit

public class SelectionCardHighlightLabel: UIView {
    var selectionCardModel: SelectionCardModel

    // MARK: - Initializer
    public init(selectionCardModel: SelectionCardModel) {
        self.selectionCardModel = selectionCardModel
        super.init(frame: .zero)
        setupView()
    }

    // code coverage tool ignore
    @available(*, unavailable)
    required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        setupHighlightLabelSection()
    }

    private func setupHighlightLabelSection() {
        let highlightLabelSection = UIView()
        highlightLabelSection.backgroundColor = selectionCardModel.cardState == .selected ?
        SmokingCessation.primaryColor : .gray
        highlightLabelSection.mxAddTopCorners(radius: 12)
        highlightLabelSection.translatesAutoresizingMaskIntoConstraints = false
        addSubview(highlightLabelSection)
        NSLayoutConstraint.activate([
            highlightLabelSection
                .leftAnchor.constraint(equalTo: self.leftAnchor),
            highlightLabelSection.rightAnchor.constraint(equalTo: self.rightAnchor),
            highlightLabelSection.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
        setupLabelTextContent(highlightLabelSection: highlightLabelSection)
    }

    private func setupLabelTextContent(highlightLabelSection: UIView) {
        let labelText = UILabel()
        labelText.numberOfLines = 0
        labelText.translatesAutoresizingMaskIntoConstraints = false
        labelText.accessibilityIdentifier = "labelTextSelectionCardHighlightLabel"
        highlightLabelSection.addSubview(labelText)
        NSLayoutConstraint.activate([
            labelText.topAnchor.constraint(equalTo: highlightLabelSection.topAnchor, constant: 4),
            labelText.bottomAnchor.constraint(equalTo: highlightLabelSection.bottomAnchor, constant: -20),
            labelText.rightAnchor.constraint(equalTo: highlightLabelSection.rightAnchor, constant: -16),
            labelText.leftAnchor.constraint(equalTo: highlightLabelSection.leftAnchor, constant: 16)
        ])
        switch selectionCardModel.cardState {
        case .selected:
            labelText.attributedText = NSAttributedString(
                string: selectionCardModel.highlightLabel!,
                attributes: SmokingCessation.textLabelEmphasizeXs
                    .color(.white)
                    .alignment(.center)
            )
        case .normal:
            labelText.attributedText = NSAttributedString(
                string: selectionCardModel.highlightLabel!,
                attributes: SmokingCessation.textLabelEmphasizeXs
                    .color(.black)
                    .alignment(.center)
            )
        }
    }
}
