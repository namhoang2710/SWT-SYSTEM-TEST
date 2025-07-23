//
//  ErrorStackView.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit

class ErrorStackView: UIStackView {
    lazy var errorIcon: UIImageView = {
        let imageView = UIImageView(image: .icError.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        return imageView
    }()

    lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private var errorMessageAlignment: NSTextAlignment = .center
    private var itemsSpacing: CGFloat = 4
    private var stackViewAlignment: UIStackView.Alignment = .top

    // Initializer
    init(
        errorMessageAlignment: NSTextAlignment = .center,
        itemsSpacing: CGFloat = 4,
        stackViewAlignment: UIStackView.Alignment = .top
    ) {
        super.init(frame: .zero)
        self.itemsSpacing = itemsSpacing
        self.errorMessageAlignment = errorMessageAlignment
        self.stackViewAlignment = stackViewAlignment
        setupView()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        axis = .horizontal
        spacing = itemsSpacing
        distribution = .fillProportionally
        alignment = stackViewAlignment
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        addArrangedSubview(errorIcon)
        addArrangedSubview(errorMessageLabel)
        NSLayoutConstraint.activate([
            errorIcon.widthAnchor.constraint(equalToConstant: 16)
        ])
    }

    // Public method to update the message
    func showErrorMessage(_ message: String) {
        errorMessageLabel.attributedText = NSAttributedString(
            string: message,
            attributes: SmokingCessation.textLabelDefaultS
                .color(.red)
                .paragraphStyle(lineSpacing: 0, alignment: errorMessageAlignment)
        )
        isHidden = false
    }

    // Public method to hide the error
    func hideError() {
        isHidden = true
    }
}
