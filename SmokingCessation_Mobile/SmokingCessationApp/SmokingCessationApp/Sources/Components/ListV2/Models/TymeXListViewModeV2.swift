//
//  TymeXListViewModeV2.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 14/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public enum TymeXListViewModeV2 {
    case noBorderMode
    case borderMode

    func getBorderWidth() -> CGFloat {
        switch self {
        case .borderMode:
            return 1
        case .noBorderMode:
            return 0
        }
    }

    func getBorderColor() -> UIColor {
        switch self {
        case .borderMode:
            return SmokingCessation.colorDividerDividerBase
        case .noBorderMode:
            return SmokingCessation.colorStrokeInfoBase
        }
    }

    func getCornerRadius() -> CGFloat {
        switch self {
        case .borderMode:
            return SmokingCessation.cornerRadius3
        case .noBorderMode:
            return 0
        }
    }
}
