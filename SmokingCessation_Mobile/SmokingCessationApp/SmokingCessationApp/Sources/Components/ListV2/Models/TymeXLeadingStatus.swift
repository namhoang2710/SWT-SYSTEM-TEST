//
//  TymeXLeadingStatus.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 06/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
// swiftlint:disable empty_enum_arguments

import Foundation
import UIKit

public enum TymeXLeadingStatus {
    case avatar(TymeXAvatarModel?)
    case icon(UIImage?, Bool)
    case flag(UIImage?)

    func getModel() -> Any? {
        switch self {
        case .avatar(let avatarModel):
            return avatarModel
        case .icon(let imageIcon, let isCircleBackground):
            return (imageIcon, isCircleBackground)
        case .flag(let imageFlag):
            return imageFlag
        }
    }

    func isAvatar() -> Bool {
        switch self {
        case .avatar(_):
            return true
        case .icon(_, _), .flag(_):
            return false
        }
    }

    func getView() -> UIView? {
        switch self {
        case .avatar(let avatarModel):
            return TymeXAvatar(model: avatarModel)
        case .icon(let image, let isCircleBackground):
            if !isCircleBackground {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                return imageView
            }
            let avatarModel = TymeXAvatarModel(
                iconImage: image, isCircleBackground: isCircleBackground
            )
            return TymeXAvatar(model: avatarModel)
        case .flag(let image):
            return UIImageView(image: image)
        }
    }

    func getWidth() -> CGFloat {
        switch self {
        case .avatar(_):
            return TymeXAvatarSize.sizeL.size
        case .icon(_, let isCircleBackground):
            return isCircleBackground ? TymeXAvatarSize.sizeL.size : 24.0
        case .flag(_):
            return 24.0
        }
    }

    func getHeight() -> CGFloat {
        switch self {
        case .avatar(_):
            return TymeXAvatarSize.sizeL.size
        case .icon(_, let isCircleBackground):
            return isCircleBackground ? TymeXAvatarSize.sizeL.size : 24.0
        case .flag(_):
            return 24.0
        }
    }
}
// swiftlint:enable empty_enum_arguments
