//
//  SmokingCessation+Text.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 22/6/25.
//

import Foundation

public extension SmokingCessation {
    /// DEPRECATED: This token is to cover old usage, no longer in scope and will be removed soon. Use amount.local.currency instead.
    static let amountCurrency: String = "đ"

    /// DEPRECATED: This token is to cover old usage, no longer in scope and will be removed soon. Use amount.local.decimal-display instead.
    static let amountDecimalDisplay: String = "1"

    /// DEPRECATED: This token is to cover old usage, no longer in scope and will be removed soon. Use amount.local.decimal-seperator instead.
    static let amountDecimalSeperator: String = "."

    /// DEPRECATED: This token is to cover old usage, no longer in scope and will be removed soon. Use amount.local.design-mapper instead.
    static let amountDesignMapper: String = "0.​00"

    /// The currency symbol for the US dollar
    static let amountDollarCurrency: String = "$"

    /// Controls decimal display for US dollar. 0: no separator/decimals, 1: always show separator and 2 decimals, 2: show separator/decimals only if non-zero
    static let amountDollarDecimalDisplay: String = "1"

    /// The setting for separator of decimal number for US dollar
    static let amountDollarDecimalSeperator: String = "."

    /// This token is to use in Figma to control the amount format for US dollar
    static let amountDollarDesignMapper: String = "0.00"

    /// The setting for separator of whole value for US dollar
    static let amountDollarWholeValueSeparator: String = ","

    /// The currency symbol for the local currency
    static let amountLocalCurrency: String = "VND"

    /// Controls decimal display for local currency. 0: no separator/decimals, 1: always show separator and 2 decimals, 2: show separator/decimals only if non-zero
    static let amountLocalDecimalDisplay: String = "2"

    /// The setting for separator of decimal number for local currency
    static let amountLocalDecimalSeperator: String = "."

    /// This token is to use in Figma to control the amount format for local currency
    static let amountLocalDesignMapper: String = "0​.00"

    /// The setting for separator of whole value for local currency
    static let amountLocalWholeValueSeparator: String = ","

    /// DEPRECATED: This token is to cover old usage, no longer in scope and will be removed soon. Use amount.local.whole-value-separator instead.
    static let amountWholeValueSeparator: String = ","

}
