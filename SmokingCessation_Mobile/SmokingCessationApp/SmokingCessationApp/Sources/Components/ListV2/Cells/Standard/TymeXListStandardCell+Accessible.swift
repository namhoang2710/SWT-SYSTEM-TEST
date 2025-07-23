//
//  TymeXListStandardCell+Accessible.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 22/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation

extension TymeXListStandardCell {
    public func setupAccessibility() {
        let currentIndexText = "_index_\(currentIndex)"
        // leading content
        leadingTitle.accessibilityIdentifier = "leadingTitle\(type(of: self))\(currentIndexText)"
        leadingSubTitle1.accessibilityIdentifier = "leadingSubTitle1\(type(of: self))\(currentIndexText)"
        leadingsubTitle2.accessibilityIdentifier = "leadingSubTitle2\(type(of: self))\(currentIndexText)"
        leadingAddOnStatus.accessibilityIdentifier = "leadingAddOnStatus\(type(of: self))\(currentIndexText)"
        leadingAddOnButton?.accessibilityIdentifier = "leadingAddOnButton\(type(of: self))\(currentIndexText)"

        // trailing content
        trailingTitle.accessibilityIdentifier = "trailingTitle\(type(of: self))\(currentIndexText)"
        trailingSubTitle1.accessibilityIdentifier = "trailingSubTitle1\(type(of: self))\(currentIndexText)"
        trailingSubTitle2.accessibilityIdentifier = "trailingSubTitle2\(type(of: self))\(currentIndexText)"
        trailingAmount.accessibilityIdentifier = "trailingAmount\(type(of: self))\(currentIndexText)"

        // leadingView
        leadingView?.isAccessibilityElement = true
        leadingView?.accessibilityIdentifier = "leadingView\(type(of: self))\(currentIndexText)"

        // trailingView
        trailingView?.isAccessibilityElement = true
        trailingView?.accessibilityIdentifier = "trailingView\(type(of: self))\(currentIndexText)"
        lineView.accessibilityIdentifier = "lineView\(type(of: self))\(currentIndexText)"
    }
}
