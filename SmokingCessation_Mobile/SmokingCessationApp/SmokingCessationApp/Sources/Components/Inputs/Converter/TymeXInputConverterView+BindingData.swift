//
//  TymeXInputConverterView+BindingData.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 31/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation

extension TymeXInputConverterView {
    func bindingData() {
        // The UI should collapse whenever the user starts inputting
        fromInputAmount.onBeginEditing = { [weak self] in
            guard let self = self else { return }
            self.inputAmountSelected = self.fromInputAmount
            if self.toInputAmount.isErrorState() {
                resetErrorState(isFromField: true)
            }
        }

        toInputAmount.onBeginEditing = { [weak self] in
            guard let self = self else { return }
            self.inputAmountSelected = self.toInputAmount
            if self.fromInputAmount.isErrorState() {
                resetErrorState(isFromField: false)
            }
        }

        // Closure for handle value changed
        fromInputAmount.onValueChanged = { [weak self] amount in
            guard let self = self, self.fromInputAmount == self.inputAmountSelected else { return }
            self.onFromValueChanged?(amount)
        }

        toInputAmount.onValueChanged = { [weak self] amount in
            guard let self = self, self.toInputAmount == self.inputAmountSelected else { return }
            self.onToValueChanged?(amount)
        }

        toInputAmount.onEstimatedArrivalTapped = { [weak self] in
            guard let self = self else { return }
            self.onEstimatedArrivalTapped?()
        }
    }
}
