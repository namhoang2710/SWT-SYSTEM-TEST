//
//  ButtonConfiguration.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import UIKit

public struct ButtonConfiguration {
    public var contentMode: ContentMode
    public var showLoadingForTouchUpInside: Bool = true
    public var lottieAnimationName: String

    var trailingIconSpacing: CGFloat
    var iconWidth: CGFloat
    var spacingIconAndText: CGFloat
    var buttonHeight: CGFloat
    var animationSize: CGFloat = 24.0
    var trailingTitleSpacing: CGFloat?

    public enum ContentMode {
        case text(String)
        case trailingIcon(UIImage?, String)
    }

    public init(
        contentMode: ContentMode = .text("title"),
        lottieAnimationName: String = SmokingCessation.loadingAnimation,
        trailingIconSpacing: CGFloat = 8,
        iconWidth: CGFloat = 24,
        spacingIconAndText: CGFloat = 12,
        buttonHeight: CGFloat = 48,
        animationSize: CGFloat = 24.0,
        trailingTitleSpacing: CGFloat? = nil
    ) {
        self.contentMode = contentMode
        self.lottieAnimationName = lottieAnimationName
        self.trailingIconSpacing = trailingIconSpacing
        self.iconWidth = iconWidth
        self.spacingIconAndText = spacingIconAndText
        self.buttonHeight = buttonHeight
        self.animationSize = animationSize
        self.trailingTitleSpacing = trailingTitleSpacing
    }
}
