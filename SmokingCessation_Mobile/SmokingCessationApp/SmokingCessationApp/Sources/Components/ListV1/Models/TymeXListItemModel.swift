//
//  TymeXListItemModel.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 11/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public protocol TymeXListItemUIAttributes {
    var subTitleColor: UIColor { get }
    var titleColor: UIColor { get }
    var contentColor: UIColor { get }
}

private enum TymeXConstants {
    enum SubTitle {
        static let processing = "Processing"
        static let failed = "Failed"
    }
}

/// A model that represents an item in a list for TymeX.
///
/// - Note: This struct is deprecated. Please use `TymeXListItemModelV2` instead.
@available(*, deprecated, message: "Use 'TymeXListItemModelV2' instead.")
public struct TymeXListItemModel {
    public var uniqueKey: String = ""
    public var title: String = ""
    public var subTitle: String = ""
    public var content: String?
    public var leftIcon: UIImage?
    public var isFavourite: Bool?
    public var badgeImage: UIImage?
    public var avatarURL: String?
    public var accountName: String?
    public var listType: TymeXListType = .transactionList

    var rightIcon: UIImage?
    var moneySource: TymeXListMoneySource = .undefined
    var transactionStatus: TymeXListTransactionStatus = .undefined
    var customizeColors: [TymeXColorAttributeOfList] = []

    /**
        Transaction list style
     */
    public init(
        transactionStyleTitle: String,
        amount: String,
        leftIcon: UIImage?,
        moneySource: TymeXListMoneySource,
        transactionStatus: TymeXListTransactionStatus,
        customizeColors: [TymeXColorAttributeOfList] = [],
        uniqueKey: String = ""
    ) {
        self.title = transactionStyleTitle
        self.content = amount
        self.leftIcon = leftIcon
        self.moneySource = moneySource
        self.transactionStatus = transactionStatus
        self.customizeColors = customizeColors
        self.uniqueKey = uniqueKey
        self.listType = .transactionList
        switch transactionStatus {
        case .processing:
            subTitle = TymeXConstants.SubTitle.processing
        case .failed:
            subTitle = TymeXConstants.SubTitle.failed
        case .successful, .undefined:
            subTitle = ""
        }
    }

    /**
        Value Display style
     */
    public init(
        valueDisplayStyleTitle: String,
        subTitle: String = "",
        iconLeft: UIImage?,
        content: String = "",
        customizeColors: [TymeXColorAttributeOfList] = [],
        uniqueKey: String = ""
    ) {
        self.title = valueDisplayStyleTitle
        self.subTitle = subTitle
        self.leftIcon = iconLeft
        self.content = content
        self.customizeColors = customizeColors
        self.uniqueKey = uniqueKey
        self.listType = .itemList
    }

    /**
        Item navigational style
     */
    public init(
        navigationStyleTitle: String,
        subTitle: String = "",
        leftIcon: UIImage?,
        rightIcon: UIImage? ,
        customizeColors: [TymeXColorAttributeOfList] = [],
        uniqueKey: String = ""
    ) {
        self.title = navigationStyleTitle
        self.subTitle = subTitle
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.customizeColors = customizeColors
        self.uniqueKey = uniqueKey
        self.listType = .navigationalList
    }

    /**
        Account List style
     */
    public init(
        accountStyleTitle: String,
        subTitle: String = "",
        content: String = "",
        avatarURL: String? = nil,
        avatarImage: UIImage? = nil,
        accountName: String? = nil,
        badgeImage: UIImage? = nil,
        isFavourite: Bool? = nil,
        customizeColors: [TymeXColorAttributeOfList] = [],
        uniqueKey: String = ""
    ) {
        self.title = accountStyleTitle
        self.subTitle = subTitle
        self.content = content
        self.avatarURL = avatarURL
        self.leftIcon = avatarImage
        self.accountName = accountName
        self.badgeImage = badgeImage
        self.isFavourite = isFavourite
        self.customizeColors = customizeColors
        self.uniqueKey = uniqueKey
        self.listType = .accountList
    }

    public init(listType: TymeXListType) {
        self.listType = listType
    }

    public mutating func updateIsFavourite(to newValue: Bool) {
        isFavourite = newValue
    }
}

extension TymeXListItemModel: TymeXListItemUIAttributes {
    public var subTitleColor: UIColor {
        if !customizeColors.isEmpty {
            for colorAttribute in customizeColors
            where colorAttribute.key == .subTitleLabel {
                return colorAttribute.value
            }
        }
        switch transactionStatus {
        case .processing:
            return SmokingCessation.colorTextWarning
        case .failed:
            return SmokingCessation.colorTextError
        case .successful, .undefined:
            return SmokingCessation.colorTextSubtle
        }
    }

    public var titleColor: UIColor {
        if !customizeColors.isEmpty {
            for colorAttribute in customizeColors
            where colorAttribute.key == .titleLabel {
                return colorAttribute.value
            }
        }
        return SmokingCessation.colorTextDefault
    }

    public var contentColor: UIColor {
        if !customizeColors.isEmpty {
            for colorAttribute in customizeColors
            where colorAttribute.key == .contentLabel {
                return colorAttribute.value
            }
        }
        switch moneySource {
        case .undefined:
            return SmokingCessation.colorTextDefault
        case .moneyOut:
            return SmokingCessation.colorTextDefault
        case .moneyIn:
            return SmokingCessation.colorTextSuccess
        }
    }
}

extension TymeXListItemModel {
    static var backgroundColor: UIColor {
        return .white
    }

    static var cornerRadius: CGFloat {
        return SmokingCessation.cornerRadius4
    }

    var borderColor: UIColor {
        switch listType {
        case .transactionList:
            return .white
        case .itemList, .navigationalList, .accountList:
            return SmokingCessation.colorStrokeInfoBase
        }
    }

    var borderWidth: CGFloat {
        switch listType {
        case .transactionList:
            return 0.0
        case .itemList, .navigationalList, .accountList:
            return 2.0
        }
    }

    static var topPadding: CGFloat {
        return SmokingCessation.spacing4
    }
}
