//
//  CalendarPicker+PickerDateSource.swift
//  GoTymeApp
//
//  Created by Vinh Pham on 22/06/2022.
//  Copyright © 2022 TymeDigital Vietnam. All rights reserved.
//

import UIKit

// MARK: UIPickerViewDataSource
extension TymeXCalendarPickerView: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if !self.isShow { return 0 }
        return self.localeType.dateArray(self.dateFormatType).count
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch self.localeType.dateArray(self.dateFormatType)[component] {
        case .year:
            return self.years - self.minimumDateComponent.year - self.maximumDateComponent.year
        case .month:
            return self.months
        case .day:
            return self.days
        }
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                           forComponent component: Int, reusing view: UIView?) -> UIView {
        let dateType = self.localeType.dateArray(self.dateFormatType)[component]
        let label = UILabel()
        label.textAlignment = self.localeType.alignment(dateType: dateType)

        let selectedRow = pickerView.selectedRow(inComponent: component) == row
        let typography = selectedRow ? SmokingCessation.textLabelEmphasizeM.color(SmokingCessation.colorTextLink)
            .paragraphStyle(lineSpacing: SmokingCessation.spacing1, alignment: .center) :
        SmokingCessation.textLabelDefaultM.color(SmokingCessation.colorTextDefault)
            .paragraphStyle(lineSpacing: SmokingCessation.spacing1, alignment: .center)

        let attributedString = NSMutableAttributedString()
        switch dateType {
        case .year:
            attributedString.append(
                NSAttributedString(string: self.localeType.year(row + minimumDateComponent.year),
                                   attributes: typography))
        case .month:
            attributedString.append(NSAttributedString(
                string: self.localeType.month(row + minimumDateComponent.month),
                attributes: typography))
        case .day:
            let rowValue = row
            attributedString.append(NSAttributedString(
                string: self.localeType.day(rowValue), attributes: typography))
        }
        label.attributedText = attributedString
        return label
    }
}
