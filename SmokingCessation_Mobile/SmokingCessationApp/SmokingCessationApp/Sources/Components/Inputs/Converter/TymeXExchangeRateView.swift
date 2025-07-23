//
//  ExchangeFeeCollapseView.swift
//  InternationalTransfer
//
//  Created by Duy Le on 25/7/24.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public final class TymeXExchangeRateView: UIView {
    // MARK: - LifeCycle
    public init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    public func updateExchangeRateText(_ exchangeRateText: String) {
        exchangeRateLabel.attributedText = NSAttributedString(
            string: exchangeRateText,
            attributes: SmokingCessation.textLabelDefaultS
        )
        updateUI(isError: false)
    }

    public func updateUI(isError: Bool) {
        if isError {
            contentView.makeBorder(SmokingCessation.colorStrokeErrorBase)
            middleLineView.backgroundColor = SmokingCessation.colorStrokeErrorBase
        } else {
            contentView.makeBorder(SmokingCessation.colorBackgroundInfoBase)
            middleLineView.backgroundColor = SmokingCessation.colorDividerDividerBase
        }
    }

    // MARK: - Private
    private let contentHeight: CGFloat = 36

    lazy var contentView: UIView = {
        let view = UIView()
        view.addSubview(exchangeRateLabel)
        view.makeRoundCorner(size: contentHeight / 2)
        view.backgroundColor = SmokingCessation.colorBackgroundInfoWeak
        view.translatesAutoresizingMaskIntoConstraints = false
        exchangeRateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exchangeRateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            exchangeRateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SmokingCessation.spacing4),
            exchangeRateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SmokingCessation.spacing4),
            exchangeRateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: SmokingCessation.spacing2),
            exchangeRateLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -SmokingCessation.spacing2)
        ])

        return view
    }()

    let exchangeRateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = NSAttributedString(
            string: "---",
            attributes: SmokingCessation.textLabelDefaultS
        )
        return label
    }()

    var middleLineView: UIView = {
        let view = UIView()
        view.backgroundColor = SmokingCessation.colorDividerDividerBase
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private func setupUI() {
        addSubview(middleLineView)
        addSubview(contentView)

        NSLayoutConstraint.activate([
            middleLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            middleLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            middleLineView.heightAnchor.constraint(equalToConstant: 1),
            middleLineView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: SmokingCessation.spacing4),
            contentView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -SmokingCessation.spacing4),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.heightAnchor.constraint(equalToConstant: contentHeight)
        ])
    }
}
