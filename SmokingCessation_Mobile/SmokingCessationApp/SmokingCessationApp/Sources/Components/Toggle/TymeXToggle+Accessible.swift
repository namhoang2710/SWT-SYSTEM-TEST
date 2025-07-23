//
//  TymeXToggle+Accessible.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 02/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation

extension TymeXToggle {
    public func setupAccessibility() {
        self.accessibilityIdentifier = self.accessibilityID ?? "\(type(of: self))"
        self.toggleCircle.accessibilityIdentifier = "toggleCircle\(type(of: self))"
    }
}
