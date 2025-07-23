//
//  TymeXCurrencySettings.swift
//  TymeXUIComponent
//
//  Created by Thao Lai on 02/02/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//
import Foundation
import UIKit

public enum DecimalToken {
    static let defaultToken = "0"
    static let phToken = "1"
    static let saToken = "2"
}

public final class TymeXCurrencySettings {

    let defaultValue: Double
    let showCurrencySymbol: Bool
    let maxDigits: Int
    private(set) var maximumFractionDigits: Int = 0
    private(set) var minimumFractionDigits: Int = 0

    // defined by Design Token
    let currencySymbol: String
    let amountDecimalDisplay: String
    private(set) var amountDecimalSeperator: String
    private(set) var amountWholeValueSeparator: String

    public init(
        currencySymbol: String = SmokingCessation.amountLocalCurrency,
        defaultValue: Double = 0.00,
        showCurrencySymbol: Bool = true,
        maxDigits: Int = 15,
        amountDecimalSeperator: String = SmokingCessation.amountLocalDecimalSeperator,
        amountWholeValueSeparator: String = SmokingCessation.amountLocalWholeValueSeparator,
        amountDecimalDisplay: String = SmokingCessation.amountLocalDecimalDisplay
    ) {
        self.currencySymbol = currencySymbol
        self.defaultValue = defaultValue
        self.showCurrencySymbol = showCurrencySymbol
        self.maxDigits = maxDigits
        self.amountDecimalSeperator = amountDecimalSeperator
        self.amountWholeValueSeparator = amountWholeValueSeparator
        self.amountDecimalDisplay = amountDecimalDisplay
        configFormatByToken()
    }

    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .down
        formatter.currencySymbol = ""
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.decimalSeparator = amountDecimalSeperator
        formatter.groupingSeparator = amountWholeValueSeparator
        return formatter
    }()

    lazy var placeHolderText: String = {
        let placeHolder = format(
            value: defaultValue,
            minimumFractionDigits: minimumFractionDigits
        )
        return placeHolder ?? ""
    }()

    /**
     - Parameters:
     - value: The value to format.
     - alwaysShowAsDecimal: determines whether the value should alwaysbe displayed with decimal point.
     `true`=> formatted with the minimum number of fraction digits specified by `minimumFractionDigits`.
     `false` = >  formatted without minimum number required for fraction digits. For example, 5 instead of 5.00
     - Returns: A string representation of the value, by the current locale and `alwaysShowAsDecimal` parameter.
     */
    func format(value: any Numeric, alwaysShowAsDecimal: Bool) -> String? {
        let minFractionDigits = alwaysShowAsDecimal ? self.minimumFractionDigits : 0
        return format(value: value, minimumFractionDigits: minFractionDigits)
    }

    func format(value: any Numeric, minimumFractionDigits: Int) -> String? {
        formatter.minimumFractionDigits = minimumFractionDigits
        guard let text = formatter.string(for: value) else { return "" }

        // For SA logic TDS-285
        // 1. R10.00 -> R10
        // 2. R10.10 -> R10.10
        // 3. R10.11 -> R10.11
        if SmokingCessation.amountLocalDecimalDisplay == DecimalToken.saToken
            && formatter.minimumFractionDigits == 2
            && text.split(separator: ".").last == "00" {
            return text.removeSubString(string: ".00")
        }
        return text
    }

    func configFormatByToken() {
        switch amountDecimalDisplay {
        case DecimalToken.defaultToken:
            amountDecimalSeperator = ""
            amountWholeValueSeparator = ""
            maximumFractionDigits = 0
            minimumFractionDigits = 0
        case DecimalToken.phToken, DecimalToken.saToken:
            minimumFractionDigits = 2
            maximumFractionDigits = 2
        default:
            break
        }
    }
}
