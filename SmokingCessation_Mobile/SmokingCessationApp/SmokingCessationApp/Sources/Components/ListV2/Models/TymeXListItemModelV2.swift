//
//  TymeXListItemModelV2.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 22/11/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public class TymeXListItemModelV2 {
    public var uniqueKey: String = ""
    public var leadingStatus: TymeXLeadingStatus?
    public var leadingContent: TymeXLeadingContent?
    public var trailingContentStatus: TymeXTrailingContentStatus?
    public var trailingStatus: TymeXTrailingStatus?
    public var deepLinkString: String = ""
    public var isAllowToSwipe: Bool = false
    public var isAllowToPlayHintAnimation: Bool = false
    public var listType: TymeXListTypeV2 = .standard
    public var isSingleLineType: Bool = false

    public init(
        uniqueKey: String = "",
        leadingStatus: TymeXLeadingStatus? = nil,
        leadingContent: TymeXLeadingContent? = nil,
        trailingContentStatus: TymeXTrailingContentStatus? = nil,
        trailingStatus: TymeXTrailingStatus? = nil,
        deepLinkString: String = "",
        isAllowToSwipe: Bool = false,
        isAllowToPlayHintAnimation: Bool = false,
        isSingleLineType: Bool = false,
        listType: TymeXListTypeV2
    ) {
        self.uniqueKey = uniqueKey
        self.leadingStatus = leadingStatus
        self.leadingContent = leadingContent
        self.trailingContentStatus = trailingContentStatus
        self.trailingStatus = trailingStatus
        self.deepLinkString = deepLinkString
        self.isAllowToSwipe = isAllowToSwipe
        self.isAllowToPlayHintAnimation = isAllowToPlayHintAnimation
        self.isSingleLineType = isSingleLineType
        self.listType = listType
    }
}

extension TymeXListItemModelV2 {
    static var cornerRadius: CGFloat {
        return SmokingCessation.cornerRadius4
    }

    static var topPadding: CGFloat {
        return SmokingCessation.spacing4
    }
}

public enum TymeXListTypeV2 {
    case standard
    case infor

    func getListType() -> String {
        switch self {
        case .standard:
            return "TymeXListStandardCell"
        case .infor:
            return "TymeXListInfoCell"
        }
    }
}
