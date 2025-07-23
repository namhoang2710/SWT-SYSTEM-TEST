//
//  SecondaryButton.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import Foundation
import UIKit

open class SecondaryButton: BaseButton {
    open override var minWidth: CGFloat { 72 }
    open override var height: CGFloat { 48 }
    open override var normalBorderWidth: CGFloat { 1 }
    open override var highlightedBorderWidth: CGFloat { 0 }

    open override func configColors() {
        super.configColors()
        normalColor = UIColor.clear
        highlightedColor = SmokingCessation.secondaryColor
    }

    open override func configBackgroundView() {
        super.configBackgroundView()
        configBorderLine()
    }

    open override func configTitleView() {
        super.configTitleView()
        setTitleColor(.black)
    }
}

extension SecondaryButton: OutlinedButtonProtocol {
    public func configBorderLine(
        width: CGFloat = 1,
        color: CGColor = SmokingCessation.secondaryColor.cgColor
    ) {
        backgroundView.layer.borderWidth = width
        backgroundView.layer.borderColor = color
    }
}
