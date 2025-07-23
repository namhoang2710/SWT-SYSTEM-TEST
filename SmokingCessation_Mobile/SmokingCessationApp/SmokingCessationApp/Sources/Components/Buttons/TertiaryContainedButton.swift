//
//  TymeXTertiaryContainedButton.swift
//  Component
//
//  Created by Vuong Tran on 25/09/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

open class TertiaryContainedButton: BaseButton {
    open override var height: CGFloat { 36 }
    open override var minWidth: CGFloat { 44 }
    open override var titleTypography: [NSAttributedString.Key: Any] { SmokingCessation.textLabelEmphasizeS }

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
        normalColor = SmokingCessation.colorBackgroundSecondaryBase
        highlightedColor = SmokingCessation.colorBackgroundSecondaryWeak
    }

    open override func configTitleView() {
        super.configTitleView()
        setTitleColor(SmokingCessation.colorTextInverse)
    }
}

// MARK: Privates
extension TertiaryContainedButton {
    private func makeButtonConfiguration() -> ButtonConfiguration {
        return ButtonConfiguration(
            contentMode: .text(""),
            lottieAnimationName: SmokingCessation.loadingAnimation,
            trailingIconSpacing: SmokingCessation.spacing1,
            iconWidth: 16,
            buttonHeight: 36,
            animationSize: 20
        )
    }
}
