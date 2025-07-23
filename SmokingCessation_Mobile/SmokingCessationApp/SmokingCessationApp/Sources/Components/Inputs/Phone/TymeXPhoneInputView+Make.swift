//
//  TymeXPhoneInputView+Make.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 07/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation

extension TymeXPhoneInputView {
    func makeCountryView() -> TymeXCountryCodeView {
        // init with image flag & country code
        let dropdownImage = SmokingCessation().iconChevronDown

        // init TymeXCountryCodeView
        let countryCodeView = TymeXCountryCodeView(
            flagImage: flagIcon,
            countryCode: countryCode,
            dropdownImage: dropdownImage
        )
        return countryCodeView
    }
}
