//
//  TymeXListInfoCell+Public.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 10/01/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public extension TymeXListInfoCell {
    func getLeadingTitleLabel() -> UILabel {
        return leadingTitle
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

    func getActionTextLabel() -> UILabel {
        return actionText
    }
}
