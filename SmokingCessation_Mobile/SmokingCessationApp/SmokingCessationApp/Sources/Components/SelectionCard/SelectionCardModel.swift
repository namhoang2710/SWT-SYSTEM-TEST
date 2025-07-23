//
//  SelectionCardModel.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit

/// pre-defined slot content structure
public struct PredefinedSlot {
    public var title: String
    public var badge: String?
    public var subTitle1: UILabel
    public var subTitle2: UILabel?
    public init(title: String, badge: String? = nil, subTitle1: UILabel, subTitle2: UILabel? = nil) {
        self.title = title
        self.badge = badge
        self.subTitle1 = subTitle1
        self.subTitle2 = subTitle2
    }
}

/// selection card model
public struct SelectionCardModel {
    public var highlightLabel: String?
    public var cardState: SelectionCardStates = .normal
    public var topSlotOption: SelectionCardSlotOption
    public var bottomSlotView: UIView?
    public var errorMessage: String?
    public var isErrorMessageShown: Bool
    public var propertyID: String?
    public init(
        highlightLabel: String? = nil,
        cardState: SelectionCardStates = .normal,
        topSlotOption: SelectionCardSlotOption,
        bottomSlotView: UIView? = nil,
        errorMessage: String? = nil,
        isErrorMessageShown: Bool = true,
        propertyID: String? = nil
    ) {
        self.highlightLabel = highlightLabel
        self.cardState = cardState
        self.topSlotOption = topSlotOption
        self.bottomSlotView = bottomSlotView
        self.errorMessage = errorMessage
        self.isErrorMessageShown = isErrorMessageShown
        self.propertyID = propertyID
    }
}

extension SelectionCardModel {
    /// Boolean variable to heck if error message is not null and not empty
    var hasErrorMessage: Bool {
        return errorMessage?.isEmpty == false
    }
}
