//
//  TextButton.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import UIKit
import Lottie

open class TextButton: BaseButton {
    open override var height: CGFloat { 36 }
    open override var minWidth: CGFloat { 51 }
    open override var titleTypography: [NSAttributedString.Key: Any] {
        SmokingCessation.textLabelEmphasizeS.alignment(.right) }
    open override var normalBorderWidth: CGFloat { 0 }
    open override var highlightedBorderWidth: CGFloat { 0 }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(configuration: makeTextButtonConfiguration())
        titleView.addArrangedSubview(UIView())
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(configuration: makeTextButtonConfiguration())
        titleView.addArrangedSubview(UIView())
    }

    public override func setTitle(with mode: ButtonConfiguration.ContentMode) {
        super.setTitle(with: mode)
        if case .trailingIcon(let image, _) = mode {
            if let image = image {
                imageView.image = image.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = SmokingCessation.secondaryColor
            } else {
                imageView.removeFromSuperview()
            }
        }
    }

    open override func configColors() {
        super.configColors()
        normalColor = UIColor.clear
        highlightedColor = UIColor.clear
    }

    open override func configTitleView() {
        super.configTitleView()
        setTitleColor(SmokingCessation.secondaryColor)
    }

    open override func configBackgroundView() {
        super.configBackgroundView()
        backgroundView.layer.borderWidth = 0
        backgroundView.layer.borderColor = UIColor.clear.cgColor
    }
}

// MARK: Privates
extension TextButton {
    private func makeTextButtonConfiguration() -> ButtonConfiguration {
        return ButtonConfiguration(
            trailingIconSpacing: 4,
            iconWidth: 16,
            trailingTitleSpacing: 0
        )
    }
}
