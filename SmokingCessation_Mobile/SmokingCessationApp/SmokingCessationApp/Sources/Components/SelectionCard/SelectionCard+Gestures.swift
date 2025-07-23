//
//  SelectionCard+Gestures.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit

// MARK: - Handling tap gesture
extension SelectionCard {
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        addGestureRecognizer(tapGesture)
    }

    @objc func handleCardTap() {
        if let checkbox = checkboxContainerView.subviews.first(where: { $0 is Checkbox }) as? Checkbox {
            checkbox.isChecked.toggle()
            handleCheckboxToggle(isChecked: checkbox.isChecked)
            onStateChanged?(model)
            setupHighLightLabel()
            setupSlotContainerView()
        }
    }
}
