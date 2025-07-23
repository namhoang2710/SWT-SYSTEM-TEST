//
//  NavigationBarStylist.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import UIKit

public class NavigationBarStylist {
    public var mode: NavigationMode
    public var center: NavigationTitleViewStyle
    public var left: BarButtonItemStyle
    public var right: BarButtonItemStyle

    /**
        Customize style:  [---]           [---]           [---]
     */
    public init(
        mode: NavigationMode,
        center: NavigationTitleViewStyle,
        left: BarButtonItemStyle,
        right: BarButtonItemStyle
    ) {
        self.mode = mode
        self.center = center
        self.left = left
        self.right = right
    }

    /**
        Default style:  [Back Button]           [Title]           []
     */
    public init(
        mode: NavigationMode,
        title: String
    ) {
        self.mode = mode
        center = .byDefault(title: title)
        switch mode {
        case .light:
            left = BarButtonItemStyle.lightBackButton
        case .dark:
            left = BarButtonItemStyle.darkBackButton
        }
        right = .empty
    }

    /**
        Right Icon style:  [Back Button]           [Title/Subtitle]           []
     */
    public init(
        mode: NavigationMode,
        title: String,
        subTitle: String
    ) {
        self.mode = mode
        center = .twoLines(title: title, subTitle: subTitle)
        switch mode {
        case .light:
            left = BarButtonItemStyle.lightBackButton
        case .dark:
            left = BarButtonItemStyle.darkBackButton
        }
        right = .empty
    }

    /**
        Right Icon style:  [Back Button]           [Title/Subtitle]           [Right Icon]
     */
    public init(
        mode: NavigationMode,
        title: String,
        subTitle: String,
        rightIcon: UIImage?
    ) {
        self.mode = mode
        self.center = .twoLines(title: title, subTitle: subTitle)
        switch mode {
        case .light:
            left = BarButtonItemStyle.lightBackButton
        case .dark:
            left = BarButtonItemStyle.darkBackButton
        }
        right = .icon(rightIcon)
    }

    /**
        Right Button style:  [Back Button]           [Title/Subtitle]           [Right Button]
     */
    public init(
        mode: NavigationMode,
        title: String,
        subTitle: String,
        rightText: String
    ) {
        self.mode = mode
        center = .twoLines(title: title, subTitle: subTitle)
        switch mode {
        case .light:
            left = BarButtonItemStyle.lightBackButton
        case .dark:
            left = BarButtonItemStyle.darkBackButton
        }
        right = .button(rightText)
    }
}

extension NavigationBarStylist: Equatable {
    public static func == (
        lhs: NavigationBarStylist,
        rhs: NavigationBarStylist
    ) -> Bool {
        return lhs.mode == rhs.mode
        && lhs.left == rhs.left
        && lhs.right == rhs.right
        && lhs.center == rhs.center
    }
}
