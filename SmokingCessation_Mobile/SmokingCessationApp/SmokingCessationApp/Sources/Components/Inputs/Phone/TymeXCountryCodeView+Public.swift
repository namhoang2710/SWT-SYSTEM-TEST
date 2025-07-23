//
//  TymeXCountryCodeView+Public.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 05/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXCountryCodeView {
    // Method to update the flag image, country code, and dropdown image
    public func update(flagImage: UIImage?, countryCode: String, dropdownImage: UIImage?) {
        if let newFlagImage = flagImage {
            flagImageView.image = newFlagImage
        }
        codeLabel.attributedText = NSAttributedString(
            string: countryCode,
            attributes: SmokingCessation.textLabelEmphasizeL.alignment(.center)
        )
        if let newDropdownImage = dropdownImage {
            dropdownImageView.image = newDropdownImage
        }
        dropdownImageView.isHidden = (dropdownImage == nil)
    }

    public func hideArrowDownIcon(flag: Bool) {
        dropdownImageView.isHidden = flag
    }

    public func getDropDownImage() -> UIImage? {
        return dropdownImage
    }
}
