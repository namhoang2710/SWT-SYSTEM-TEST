//
//  UIView+AnimateConstraints.swift
//  TymeXUIComponent
//
//  Created by Vuong Tran on 22/12/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

extension UIView {
    func mxAnimateConstraints(
        constraint: NSLayoutConstraint,
        constant: Double,
        configuration: AnimationConfiguration
    ) {
        constraint.constant = constant
        UIView.mxAnimateBy(configuration) { [weak self] in
            self?.superview?.layoutIfNeeded()
        }
    }
}
