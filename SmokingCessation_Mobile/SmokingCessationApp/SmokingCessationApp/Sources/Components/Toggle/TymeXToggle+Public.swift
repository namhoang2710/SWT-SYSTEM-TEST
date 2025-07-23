//
//  TymeXToggle+Public.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 25/02/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation

public extension TymeXToggle {
    func getToggleState() -> Bool {
        return isOn
    }

    func setToggleState(_ state: Bool, animated: Bool = true) {
        guard isOn != state else { return }
        isOn = state
        if animated {
            animateToggle()
        } else {
            updateToggleAppearance()
        }
        onToggleChanged?(isOn)
    }
}
