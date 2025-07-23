//
//  ButtonDock+Public.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

extension ButtonDock: ButtonDockProtocol {
    public func updateAmountAfterFee(amountAfterFeeValue: Double) {
        let startStrikeThroughLocation = 1
        // amount after fee
        if let model = getModel(type: .amountAfterFee) {
            let textValue = amountAfterFeeValue.formatAmountWithCurrencySymbol()
            let length = textValue.length - startStrikeThroughLocation
            updateFeeValueWithModel(
                feeModel: model,
                textValue: textValue,
                startStrikeThroughLocation: startStrikeThroughLocation,
                lengthStrikeThrough: length
            )
        }

        // Others type
        for model in feeFooterModels where model.type != .amountAfterFee {
            let textValue = model.feeValue.formatAmountWithCurrencySymbol()
            let length = textValue.length - startStrikeThroughLocation
            updateFeeValueWithModel(
                feeModel: model,
                textValue: textValue,
                startStrikeThroughLocation: startStrikeThroughLocation,
                lengthStrikeThrough: length
            )
        }
    }

    public func updateFeeValueWithModel(
        feeModel: FeeModel, textValue: String,
        startStrikeThroughLocation: Int = 1, lengthStrikeThrough: Int = 0) {
            let attribute = SmokingCessation.textLabelEmphasizeS.color(.black)
        let stackView = stackView(for: feeModel.type)
        if feeModel.isStrikeThrough {
            stackView?.1.setStrikethrough(
                text: textValue,
                startLocation: startStrikeThroughLocation,
                length: lengthStrikeThrough,
                attribute: attribute
            )
        } else {
            stackView?.1.text = (textValue == "đ") ? Constants.defaultTextValue : textValue
        }
        stackView?.2.text = feeModel.description
    }

    public func insertModel(model: FeeModel, index: Int) {
        guard case TermsFeeStatus.fee(_) = termsFeeStatus else { return }

        feeFooterModels.insert(model, at: index)
        if let stackView = createFeeStackViewAndAddToMainFeeStackView(for: model) {
            mainFeeStackView.insertArrangedSubview(stackView, at: index)
            updateFeeValueWithModel(feeModel: model, textValue: "\(model.feeValue)")
        }
    }

    public func removeModel(at index: Int) {
        guard case TermsFeeStatus.fee(_) = termsFeeStatus else { return }

        // Remove model from data source
        feeFooterModels.remove(at: index)

        // Remove view from stack view
        if index < mainFeeStackView.arrangedSubviews.count {
            let viewToRemove = mainFeeStackView.arrangedSubviews[index]
            mainFeeStackView.removeArrangedSubview(viewToRemove)
            viewToRemove.removeFromSuperview()
        }
    }

    public func getTermLabel() -> UILabel {
        return termLabel
    }

    public func getHelperLabel() -> UILabel {
        return helperLabel
    }

    public func getCheckBox() -> Checkbox {
        return checkbox
    }

    public func showLineView(flag: Bool) {
        lineView.isHidden = !flag
    }

    public func showTermView(flag: Bool) {
        termStackView.isHidden = !flag
    }

    public func showErrorMessage(message: String, flag: Bool) {
        self.errorMessage = message
        errorStackView.showErrorMessage(errorMessage)
        errorContainer.isHidden = !flag
    }
}
