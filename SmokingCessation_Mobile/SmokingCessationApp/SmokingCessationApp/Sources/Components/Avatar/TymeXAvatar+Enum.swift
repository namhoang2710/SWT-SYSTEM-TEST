//
//  TymeXAvatar+Enum.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 22/11/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation

public enum TymeXAvatarType {
    case avatar
    case initials
    case icon

    func getText() -> String {
        switch self {
        case .avatar:
            return "Avatar"
        case .initials:
            return "Initial"
        case .icon:
            return "Icon"
        }
    }
}

public enum TymeXAvatarSize: String, CaseIterable {
    case sizeL
    case sizeM
    case sizeXL

    public var size: CGFloat {
        switch self {
        case .sizeL: return 48
        case .sizeM: return 36
        case .sizeXL: return 64
        }
    }

    public static func fromIndex(_ index: Int) -> TymeXAvatarSize? {
        guard index >= 0 && index < allCases.count else {
            return nil
        }
        return allCases[index]
    }

    public static func index(of size: TymeXAvatarSize) -> Int {
        return allCases.firstIndex(of: size) ?? 0
    }
}
