//
//  TymeXExchangeInputAmountView+Actions.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 31/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXExchangeInputAmountView {
    @objc
    func didViewTapped() {
        inputAmountTextField.becomeFirstResponder()
    }

    @objc
    func didEstimatedArrivalTapped() {
        onEstimatedArrivalTapped?()
    }
}
