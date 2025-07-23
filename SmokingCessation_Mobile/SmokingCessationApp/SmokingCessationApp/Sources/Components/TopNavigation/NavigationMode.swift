//
//  NavigationMode.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import UIKit

public protocol NavigationBarModeAttribute {
    var tintColor: UIColor { get }
    var textColor: UIColor { get }
}

public enum NavigationMode: Equatable {
    case light(_ tintColor: UIColor? = nil)
    case dark(_ tintColor: UIColor? = nil)

    private var lightTintColor: UIColor {
        return .white
    }
    private var darkTintColor: UIColor {
        return .gray
    }
}

extension NavigationMode: NavigationBarModeAttribute {
    public var textColor: UIColor {
        switch self {
        case .light:
            return .black
        case .dark:
            return .white
        }
    }

    public var tintColor: UIColor {
        var tint: UIColor
        switch self {
        case .light(let color):
            if let color = color {
                tint = color
            } else {
                tint = lightTintColor
            }
        case .dark(let color):
            if let color = color {
                tint = color
            } else {
                tint = darkTintColor
            }
        }
        return tint
    }
}
