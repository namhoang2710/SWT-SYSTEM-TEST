//
//  TymeXLeadingContent.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 06/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation

public class TymeXLeadingContent {
    public var title: String?
    public var subTitle1: String?
    public var subTitle2: String?
    public var isHighlightTitle: Bool = false
    public var addOnLabelStatus: TymeXContentAddOnStatus?
    public var addOnButton: TymeXContentAddOnButton?

    public init(
        title: String? = nil, subTitle1: String? = nil,
        subTitle2: String? = nil, isHighlightTitle: Bool = false,
        addOnLabelStatus: TymeXContentAddOnStatus? = nil,
        addOnButtonStatus: TymeXContentAddOnButton? = nil
    ) {
        self.title = title
        self.subTitle1 = subTitle1
        self.subTitle2 = subTitle2
        self.isHighlightTitle = isHighlightTitle
        self.addOnLabelStatus = addOnLabelStatus
        self.addOnButton = addOnButtonStatus
    }
}
