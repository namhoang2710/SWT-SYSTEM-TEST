//
//  TymeXPasscodeInputView+Animation.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 16/01/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXPasscodeInputView {
    func animateScaleUp(
        passcodeField: TymeXPasscodeField,
        completionHandler: ((Bool) -> Void)?) {
        DispatchQueue.main.async {
            passcodeField.currentState = .filledState
            UIView.animate(
                withDuration: ConstantsPasscode.animationDuration,
                delay: 0, options: .curveEaseIn, animations: {
                    passcodeField.circleView.transform = CGAffineTransform(
                        scaleX: ConstantsPasscode.scaleWidthRatio,
                        y: ConstantsPasscode.scaleWidthRatio
                    )
            }, completion: { [weak self] _ in
                self?.animateScaleDown(
                    passcodeField: passcodeField, completionHandler: completionHandler
                )
            })
        }
    }

    func animateScaleDown(
        passcodeField: TymeXPasscodeField,
        completionHandler: ((Bool) -> Void)?) {
        UIView.animate(
            withDuration: ConstantsPasscode.animationDuration,
            delay: 0, options: .curveEaseOut, animations: {
            passcodeField.circleView.transform = .identity
        }, completion: completionHandler)
    }
}
