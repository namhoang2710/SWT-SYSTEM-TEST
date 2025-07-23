//
//  TymeXInputConverterView+Setup.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 31/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXInputConverterView {
    func setupUI(with configuration: TymeXInputConverterConfiguration) {
        setupFromInputAmount(configuration: configuration)
        setupToInputAmount(configuration: configuration)
        setupExchangeRateView(configuration: configuration)
        setupMainStackView()
    }

    func setupFromInputAmount(configuration: TymeXInputConverterConfiguration) {
        fromInputAmount = TymeXExchangeInputAmountView(configuration: .init(
            title: configuration.fromTitle,
            currencyType: configuration.fromCurrencyType,
            isReceiver: configuration.fromIsReceiver,
            isHiddenDropDownIcon: configuration.fromIsHiddenDropDownIcon
        ))
        fromInputAmount.setupMainStackView()
        inputAmountSelected = fromInputAmount
    }

    func setupToInputAmount(configuration: TymeXInputConverterConfiguration) {
        toInputAmount = TymeXExchangeInputAmountView(configuration: .init(
            title: configuration.toTitle,
            currencyType: configuration.toCurrencyType,
            isReceiver: configuration.toIsReceiver,
            isHiddenDropDownIcon: configuration.toIsHiddenDropDownIcon
        ))

        toInputAmount.updateFooterTitle(
            configuration.footerTitle,
            icon: SmokingCessation().iconInfo,
            additionalText: configuration.footerValue
        )
        toInputAmount.setupMainStackView()
    }

    func setupExchangeRateView(configuration: TymeXInputConverterConfiguration) {
        exchangeRateView.updateExchangeRateText(configuration.exchangeRate)
    }

    func setupMainStackView() {
        addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
