//
//  TymeXInputConverterView.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 07/04/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public final class TymeXInputConverterView: UIView {
    public var configuration: TymeXInputConverterConfiguration!
    // MARK: - LifeCycle
    public init(configuration: TymeXInputConverterConfiguration) {
        super.init(frame: .zero)
        self.configuration = configuration
        setupUI(with: configuration)
        bindingData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    public var onFromValueChanged: ((Double) -> Void)?
    public var onToValueChanged: ((Double) -> Void)?
    public var onEstimatedArrivalTapped: (() -> Void)?

    // MARK: - Private
    public var inputAmountSelected: TymeXExchangeInputAmountView?
    let animationDuration: TimeInterval = 0.2
    let spacingMainStackViewItems = 18.5

    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = -spacingMainStackViewItems
        stackView.addArrangedSubview(fromInputAmount)
        stackView.addArrangedSubview(exchangeRateView)
        stackView.addArrangedSubview(toInputAmount)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public var exchangeRateView: TymeXExchangeRateView = {
        let view = TymeXExchangeRateView()
        view.layer.zPosition = 999
        return view
    }()

    public var fromInputAmount: TymeXExchangeInputAmountView!
    public var toInputAmount: TymeXExchangeInputAmountView!
}

