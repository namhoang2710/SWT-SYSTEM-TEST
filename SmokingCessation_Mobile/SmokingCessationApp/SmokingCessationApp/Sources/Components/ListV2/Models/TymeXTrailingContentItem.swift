//
//  TymeXTrailingItem.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 14/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation

public class TymeXTrailingContentItem {
    public var title: String?
    public var subTitle1: String?
    public var subTitle2: String?
    public var isHighlightTitle: Bool = false
    public var amountStatus: TymeXTrailingContentAmountStatus?
    public var textAction: String?

    public init(
        title: String? = nil, subTitle1: String? = nil,
        subTitle2: String? = nil, textAction: String? = nil,
        isHighlightTitle: Bool = false,
        amountStatus: TymeXTrailingContentAmountStatus? = nil
    ) {
        self.title = title
        self.subTitle1 = subTitle1
        self.subTitle2 = subTitle2
        self.isHighlightTitle = isHighlightTitle
        self.amountStatus = amountStatus
        self.textAction = textAction
    }
}
