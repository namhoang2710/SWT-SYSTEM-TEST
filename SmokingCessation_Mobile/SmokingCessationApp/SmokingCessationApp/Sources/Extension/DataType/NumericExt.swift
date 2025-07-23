//
//  NumericExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 22/6/25.
//

import Foundation
import UIKit

public extension Numeric {
    func formatAmount() -> String {
        guard let formatAmount = TymeXCurrencySettings().format(value: self, alwaysShowAsDecimal: true)
        else { return "" }
        return formatAmount
    }

    func formatAmountWithCurrencySymbol(_ currencySymbol: String = SmokingCessation.amountLocalCurrency) -> String {
        let currencySetting = TymeXCurrencySettings()
        let formatter = currencySetting.formatter
        formatter.positivePrefix = currencySymbol
        formatter.negativePrefix = "\(formatter.negativePrefix ?? "")\(currencySymbol)"
        return currencySetting.format(value: self, alwaysShowAsDecimal: true) ?? ""
    }
}
