//
//  TymeXAvatarModel.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 20/11/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public struct TymeXAvatarModel {
    public var uniqueKey: String = ""
    public var badgeImage: UIImage?
    public var indicatorDot: UIImage?
    public var showIndicatorDot: Bool = false
    public var avatarURL: String?
    public var avatarImage: UIImage?
    public var accountName: String?
    public var iconImage: UIImage?
    public var type: TymeXAvatarType = .avatar
    public var avatarSize: TymeXAvatarSize = .sizeL
    public var isCircleBackground: Bool = false
    public init(
        uniqueKey: String? = nil,
        avatarURL: String? = nil,
        avatarImage: UIImage? = nil,
        accountName: String? = nil,
        iconImage: UIImage? = nil,
        badgeImage: UIImage? = nil,
        indicatorDot: UIImage? = nil,
        showIndicatorDot: Bool = false,
        type: TymeXAvatarType = .avatar,
        avatarSize: TymeXAvatarSize = .sizeL,
        isCircleBackground: Bool = true
    ) {
        self.uniqueKey = uniqueKey ?? ""
        self.avatarURL = avatarURL
        self.avatarImage = avatarImage
        self.accountName = accountName
        self.iconImage = iconImage
        self.badgeImage = badgeImage
        self.showIndicatorDot = showIndicatorDot
        self.indicatorDot = indicatorDot
        self.type = type
        self.avatarSize = avatarSize
        self.isCircleBackground = isCircleBackground
    }
}
