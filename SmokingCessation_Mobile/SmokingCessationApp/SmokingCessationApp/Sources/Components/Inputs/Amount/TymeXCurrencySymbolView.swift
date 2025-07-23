//
//  CurrencySymbolView.swift
//  TymeXUIComponent
//
//  Created by Thao Lai on 02/02/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

class TymeXCurrencySymbolView: UIView {

    var currencyAttributes: [NSAttributedString.Key: Any] = SmokingCessation.textHeadingL
    let currencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()

    var customLeftView: UIView {
        let view = UIView()
        view.addSubview(currencyLabel)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -2),
            currencyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            currencyLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: -13)
        ])
        return view
    }

    init() {
        super.init(frame: .zero)
        addSubview(customLeftView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateCurrencyLabel(_ symbol: String) {
        currencyLabel.attributedText = NSAttributedString(string: symbol, attributes: currencyAttributes)
    }

    func setColor(color: UIColor) {
        currencyLabel.textColor = color
    }
}

extension TymeXCurrencyTextField {
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += SmokingCessation.spacing3
        rect.origin.y += SmokingCessation.spacing3/2
        return rect
    }
}
