//
//  UILabel+AttributedText.swift
//  TymeXUIComponent
//
//  Created by Vuong Tran on 22/12/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

extension UILabel {
    func mxAnimateAttributedText(
        attributedString: NSAttributedString,
        configuration: AnimationConfiguration
    ) {
        UIView.mxTransitionBy(
            configuration,
            for: self,
            options: [.transitionCrossDissolve]
        ) { [weak self] in
            guard let self = self else { return }
            self.attributedText = attributedString
        }
    }
}
