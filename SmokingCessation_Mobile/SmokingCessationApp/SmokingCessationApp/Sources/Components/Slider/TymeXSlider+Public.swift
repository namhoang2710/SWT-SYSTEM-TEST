//
//  TymeXSlider+Public.swift
//  TymeXUIComponent
//
//  Created by Duy Huynh on 17/4/25.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXSlider {
    // MARK: - Public Functions
    /// Show or hide the min and max labels.
    public func setLabelsVisible(_ visible: Bool) {
        minLabel.isHidden = !visible
        maxLabel.isHidden = !visible
        setNeedsLayout()
    }

    private func formattedValue(_ value: Decimal) -> String {
        if let custom = valueFormatter {
            return custom(value)
        }

        switch valueType {
        case .integer:
            let whole = NSDecimalNumber(decimal: value.rounded(scale: 0))
            return whole.stringValue
        case .decimal(let places):
            guard let places = places else {
                return value.formatAmount()
            }
            let fmt = NumberFormatter()
            fmt.usesGroupingSeparator  = false
            fmt.numberStyle            = .decimal
            fmt.minimumFractionDigits  = places
            fmt.maximumFractionDigits  = places
            return fmt.string(from: value as NSNumber) ?? "\(value)"
        }
    }

    /// Truncate style (showing "..." after two lines in labels)
    private func makeTruncatingAttributes() -> [NSAttributedString.Key: Any] {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineBreakMode = .byTruncatingTail

        var attrs = SmokingCessation.textBodyDefaultM.color(SmokingCessation.colorTextSubtle)
        attrs[.paragraphStyle] = paraStyle
        return attrs
    }

    /// Set up the min and max labels using the formatter or default formatting.
    public func setupMinMaxLabels() {
        let attrs  = makeTruncatingAttributes()
        let minStr = formattedValue(minimumValue)
        let maxStr = formattedValue(maximumValue)
        minLabel.attributedText = NSAttributedString(string: minStr, attributes: attrs)
        maxLabel.attributedText = NSAttributedString(string: maxStr, attributes: attrs)
    }
}
