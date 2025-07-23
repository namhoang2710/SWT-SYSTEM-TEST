//
//  TymeXListStandardCell+Public.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 02/01/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public extension TymeXListStandardCell {
    func updateLeadingTitle(attributedText: NSAttributedString) {
        leadingTitle.attributedText = attributedText
    }

    func updateTrailingTitle(attributedText: NSAttributedString) {
        trailingTitle.attributedText = attributedText
    }

    func updateLineViewWithColor(color: UIColor) {
        lineView.backgroundColor = color
    }

    func getLeadingTitleLabel() -> UILabel {
        return leadingTitle
    }

    func getLeadingSubTitle1Label() -> UILabel {
        return leadingSubTitle1
    }

    func getLeadingSubTitle2Label() -> UILabel {
        return leadingsubTitle2
    }

    func getLeadingAddOnButton() -> BaseButton? {
        return leadingAddOnButton
    }

    func getTrailingTitleLabel() -> UILabel {
        return trailingTitle
    }

    func getTrailingSubTitle1Label() -> UILabel {
        return trailingSubTitle1
    }

    func getTrailingSubTitle2Label() -> UILabel {
        return trailingSubTitle2
    }

    func getTrailingAmountLabel() -> UILabel {
        return trailingAmount
    }

    func getTrailingView() -> UIView? {
        return trailingView
    }

    func getLeadingView() -> UIView? {
        return leadingView
    }
}
