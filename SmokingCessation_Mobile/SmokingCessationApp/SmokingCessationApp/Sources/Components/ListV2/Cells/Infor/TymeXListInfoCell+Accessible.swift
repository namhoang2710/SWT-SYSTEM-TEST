//
//  TymeXListInfoCell+Accessible.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 22/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation

extension TymeXListInfoCell {
    public func setupAccessibility() {
        let currentIndexText = "_index_\(currentIndex)"

        // leading
        leadingTitle.accessibilityIdentifier = "leadingTitle\(type(of: self))\(currentIndexText)"

        // trailing content
        trailingTitle.accessibilityIdentifier = "trailingTitle\(type(of: self))\(currentIndexText)"
        trailingSubTitle1.accessibilityIdentifier = "trailingSubTitle1\(type(of: self))\(currentIndexText)"
        trailingSubTitle2.accessibilityIdentifier = "trailingSubTitle2\(type(of: self))\(currentIndexText)"
        actionText.accessibilityIdentifier = "actionText\(type(of: self))\(currentIndexText)"
    }
}
