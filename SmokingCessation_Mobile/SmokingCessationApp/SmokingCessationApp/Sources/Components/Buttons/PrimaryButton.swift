//
//  PrimaryButton.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import UIKit

open class PrimaryButton: BaseButton {
    open override var minWidth: CGFloat { 72 }

    open override var height: CGFloat { 48 }

    open override func configColors() {
        super.configColors()
        normalColor = SmokingCessation.primaryColor
        highlightedColor = SmokingCessation.primaryColor.withAlphaComponent(0.8)
    }

    open override func configTitleView() {
        super.configTitleView()
        setTitleColor(.white)
    }
}

