//
//  TymeXInputConverterConfiguration.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 01/04/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//
import UIKit

public class TymeXInputConverterConfiguration {
    // From
    public let fromTitle: String
    public let fromCurrencyType: TymeXInputConverterType
    public let fromIsReceiver: Bool
    public let fromIsHiddenDropDownIcon: Bool

    // Exchange rate
    public let exchangeRate: String
    public let footerTitle: String
    public let footerValue: String
    public var footerIcon: UIImage?

    // To
    public let toTitle: String
    public let toCurrencyType: TymeXInputConverterType
    public let toIsReceiver: Bool
    public let toIsHiddenDropDownIcon: Bool

    public init(
        fromTitle: String,
        fromCurrencyType: TymeXInputConverterType,
        fromIsReceiver: Bool,
        fromIsHiddenDropDownIcon: Bool,
        toTitle: String,
        toCurrencyType: TymeXInputConverterType,
        toIsReceiver: Bool,
        toIsHiddenDropDownIcon: Bool,
        exchangeRate: String,
        footerTitle: String,
        footerValue: String,
        footerIcon: UIImage?
    ) {
        // From
        self.fromTitle = fromTitle
        self.fromCurrencyType = fromCurrencyType
        self.fromIsReceiver = fromIsReceiver
        self.fromIsHiddenDropDownIcon = fromIsHiddenDropDownIcon

        // Exchange rate
        self.exchangeRate = exchangeRate

        // To
        self.toTitle = toTitle
        self.toCurrencyType = toCurrencyType
        self.toIsReceiver = toIsReceiver
        self.toIsHiddenDropDownIcon = toIsHiddenDropDownIcon

        // Footer
        self.footerTitle = footerTitle
        self.footerValue = footerValue
        self.footerIcon = footerIcon
    }
}
