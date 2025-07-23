//
//  TertiaryOutlinedButton.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 22/6/25.
//

import Foundation
import UIKit
import Lottie

open class TertiaryOutlinedButton: BaseButton {
    open override var height: CGFloat { 36 }
    open override var minWidth: CGFloat { 44 }
    open override var titleTypography: [NSAttributedString.Key: Any] { SmokingCessation.textLabelEmphasizeS }
    open override var normalBorderWidth: CGFloat { 1 }
    open override var highlightedBorderWidth: CGFloat { 0 }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(configuration: makeButtonConfiguration())
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(configuration: makeButtonConfiguration())
    }

    open override func configColors() {
        super.configColors()
        normalColor = UIColor.clear
        highlightedColor = SmokingCessation.colorBackgroundSecondaryExtralight
    }

    open override func configTitleView() {
        super.configTitleView()
        setTitleColor(SmokingCessation.colorTextDefault)
    }

    open override func configBackgroundView() {
        super.configBackgroundView()
        backgroundView.mxCornerRadius = height / 2
        configBorderLine()
    }
}

// MARK: Privates
extension TertiaryOutlinedButton {
    private func makeButtonConfiguration() -> ButtonConfiguration {
        return ButtonConfiguration(
            trailingIconSpacing: SmokingCessation.spacing1,
            iconWidth: 16,
            buttonHeight: 36,
            animationSize: 20
        )
    }
}

extension TertiaryOutlinedButton: OutlinedButtonProtocol {
    public func configBorderLine(
        width: CGFloat = 1,
        color: CGColor = SmokingCessation.colorStrokeSecondaryWeak.cgColor
    ) {
        backgroundView.layer.borderWidth = width
        backgroundView.layer.borderColor = color
    }
}
