//
//  TymeXTrailingStatus.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 06/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
// swiftlint:disable empty_enum_arguments

import Foundation
import UIKit
import Lottie

public enum TymeXTrailingStatus {
    case checkbox(Bool)
    case icon(UIImage?)
    case disclosure(Bool)
    case toggle(Bool)
    case favorite
    case favoriteAnimation(String)

    func getView() -> UIView {
        switch self {
        case .checkbox(let isChecked):
            let tymeXCheckbox = Checkbox()
            tymeXCheckbox.set(.init(title: "", isChecked: isChecked))
            return tymeXCheckbox
        case .icon(let image):
            return UIImageView(image: image)
        case .disclosure(let isLightMode):
            let image = isLightMode ? SmokingCessation().iconChevronRight : SmokingCessation().iconChevronRightInverse
            return UIImageView(image: image)
        case .toggle(let isOn):
            let tymeXToggle = UISwitch()
            return tymeXToggle
        case .favoriteAnimation(let lottieName):
            let lottieAnimationView = LottieAnimationView(
                animation: .named(
                    lottieName,
                    bundle: BundleSmokingCessation.bundle
                )
            )
            lottieAnimationView.contentMode = .topRight
            return lottieAnimationView
        case .favorite:
            let image = SmokingCessation().iconFavoriteFilled
            let imageView = UIImageView(image: image)
            return imageView
        }
    }

    func getWidth() -> CGFloat {
        switch self {
        case .favoriteAnimation(_):
            return 48.0
        case .favorite:
            return 24.0
        case .checkbox(_):
            return 20.0
        case .icon(_):
            return 24.0
        case .disclosure:
            return 16.0
        case .toggle(_):
            return 40.0
        }
    }

    func getHeight() -> CGFloat {
        switch self {
        case .favoriteAnimation(_):
            return 48.0
        case .favorite:
            return 24.0
        case .checkbox(_):
            return 20.0
        case .icon(_), .toggle(_):
            return 24.0
        case .disclosure:
            return 16.0
        }
    }

    func getTopSpacingEdgeInset() -> CGFloat {
        switch self {
        case .disclosure:
            return 0.0
        case .checkbox(_), .favorite,
            .icon(_), .toggle(_):
            return 0.0
        case .favoriteAnimation(_):
            return -10.0
        }
    }

    func getRightSpacingEdgeInset() -> CGFloat {
        switch self {
        case .disclosure:
            return 5.0
        case .favorite, .checkbox(_),
            .icon(_), .toggle(_):
            return 0.0
        case .favoriteAnimation(_):
            return 0.0
        }
    }

    func isFavorite() -> Bool {
        switch self {
        case .favorite, .favoriteAnimation(_):
            return true
        case .checkbox(_), .disclosure,
            .icon(_), .toggle(_):
            return false
        }
    }
}
// swiftlint:enable empty_enum_arguments
