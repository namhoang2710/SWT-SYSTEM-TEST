//
//  ExchangeInputAmountConfiguration.swift
//  InternationalTransfer
//
//  Created by Duy Le on 24/7/24.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public struct TymeXExchangeInputAmountConfiguration {

    // MARK: - LifeCycle
    public init(
        title: String, defaultAmount: Double = 0,
        currencyType: TymeXInputConverterType, isReceiver: Bool,
        isHiddenDropDownIcon: Bool = true) {
        self.title = title
        self.defaultAmount = defaultAmount
        self.currencyType = currencyType
        self.isReceiver = isReceiver
        self.isHiddenDropDownIcon = isHiddenDropDownIcon
    }

    // MARK: - Public
    public var title: String
    public var defaultAmount: Double
    public var currencyType: TymeXInputConverterType
    public var isReceiver: Bool
    public var isHiddenDropDownIcon: Bool
}
