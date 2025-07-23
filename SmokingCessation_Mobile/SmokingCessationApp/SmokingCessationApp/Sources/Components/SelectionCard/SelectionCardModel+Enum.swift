//
//  SelectionCardModel+Enum.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit
/// enum to define states of the current selection card
/// default, selected, error
@frozen
public enum SelectionCardStates: Equatable {
    case normal
    case selected
}

/// options for filling Selection Card slots
public enum SelectionCardSlotOption {
    case predefined(PredefinedSlot)
    case custom(UIView)
}
