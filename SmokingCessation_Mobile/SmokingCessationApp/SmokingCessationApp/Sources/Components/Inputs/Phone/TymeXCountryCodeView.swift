//
//  TymeXCountryCodeView.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 02/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

open class TymeXCountryCodeView: UIView {
    let flagImageView: UIImageView
    let codeLabel: UILabel
    let dropdownImageView: UIImageView
    let dropdownImage: UIImage?

    // Closure to handle tap events
    public var onTap: (() -> Void)?

    public init(flagImage: UIImage?, countryCode: String, dropdownImage: UIImage?) {
        self.flagImageView = UIImageView()
        self.codeLabel = UILabel()
        self.dropdownImageView = UIImageView()
        self.dropdownImage = dropdownImage
        super.init(frame: .zero)

        configureFlagImageView(with: flagImage)
        configureCodeLabel(with: countryCode)
        configureDropdownImageView(with: dropdownImage)

        setupStackView()
        setupGesture()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been supported anymore")
    }

    // MARK: - Configuration Methods
    private func configureFlagImageView(with image: UIImage?) {
        flagImageView.contentMode = .scaleAspectFit
        flagImageView.image = image
    }

    private func configureCodeLabel(with countryCode: String) {
        codeLabel.attributedText = NSAttributedString(
            string: countryCode,
            attributes: SmokingCessation.textLabelEmphasizeL.alignment(.center).color(SmokingCessation.colorTextDefault)
        )
        codeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        codeLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func configureDropdownImageView(with image: UIImage?) {
        dropdownImageView.contentMode = .scaleAspectFit
        dropdownImageView.tintColor = UIColor.black
        dropdownImageView.image = image
        dropdownImageView.isHidden = (image == nil)
    }

    @objc func handleTap() {
        // Call the onTap closure if it is set
        if !dropdownImageView.isHidden {
            onTap?()
        }
    }
}
