//
//  TymeXListItemAmountStatus.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 06/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//
// swiftlint:disable empty_enum_arguments

import Foundation
import UIKit

public enum TymeXTrailingContentAmountStatus {
    case defaultStatus(String)
    case add(String)
    case minus(String)
    case strikethrough(String, Bool)
    case other(String, UIColor)

    var content: String {
        switch self {
        case .defaultStatus(let content):
            return content
        case .add(let content):
            return content
        case .minus(let content):
            return content
        case .strikethrough(let content, _):
            return content
        case .other(let content, _):
            return content
        }
    }

    func getColor() -> UIColor {
        switch self {
        case .defaultStatus(_), .minus(_), .strikethrough(_, _):
            return SmokingCessation.colorTextDefault
        case .add(_):
            return SmokingCessation.colorTextSuccess
        case .other(_, let color):
            return color
        }
    }

    func getOperatorSign() -> String {
        switch self {
        case .defaultStatus(_), .other(_, _):
            return ""
        case .add(_):
            return "+"
        case .minus(_):
            return "-"
        case .strikethrough(_, let isMoneyIn):
            return isMoneyIn ? "" : "-"
        }
    }

    func getAttributeString(content: String) -> NSAttributedString {
        let operatorSign = getOperatorSign()
        let fullString = operatorSign + content
        let attributeString = NSMutableAttributedString(
            string: fullString,
            attributes: SmokingCessation.textTitleM.color(getColor())
        )
        let currencySymbolLength = SmokingCessation.amountLocalCurrency.length
        let strikethroughRangeStart = operatorSign.count + currencySymbolLength
        let strikethroughRangeLength = content.count - currencySymbolLength
        switch self {
        case .strikethrough(_, _):
            if strikethroughRangeStart < fullString.count && strikethroughRangeLength > 0 {
                attributeString.addAttribute(
                    .strikethroughStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSRange(location: strikethroughRangeStart, length: strikethroughRangeLength)
                )
            }
            return attributeString
        case .defaultStatus(_), .add(_), .minus(_), .other(_, _):
            return attributeString
        }
    }
}
// swiftlint:enable empty_enum_arguments
