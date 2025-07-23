//
//  TymeXPhoneInputView+Public.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 05/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXPhoneInputView {
    public func update(flagImage: UIImage?, countryCode: String, dropdownImage: UIImage?) {
        self.countryCodeView.update(
            flagImage: flagImage,
            countryCode: countryCode,
            dropdownImage: dropdownImage
        )
    }

    public func hideArrowDownIcon(flag: Bool) {
        self.countryCodeView.hideArrowDownIcon(flag: flag)
    }

    public func getPhoneNumber() -> String {
        return textView.text.trimmingWhiteSpace()
    }
}
