//
//  TymeXListEnums.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 11/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import Foundation

/// A type that represents different list types for TymeX.
///
/// - Note: This enum is deprecated. It doesn't used anymore.
@available(*, deprecated, message: "It doesn't used anymore")
public enum TymeXListType {
    case transactionList
    case itemList
    case navigationalList
    case accountList
}

/// A type that represents the source of money for TymeX lists.
///
/// - Note: This enum is deprecated.  It doesn't used anymore.
@available(*, deprecated, message: " It doesn't used anymore")
public enum TymeXListMoneySource {
    case moneyIn
    case moneyOut
    case undefined
}

/// A type that represents the status of a transaction in TymeX.
///
/// - Note: This enum is deprecated.  It doesn't used anymore.
@available(*, deprecated, message: " It doesn't used anymore")
public enum TymeXListTransactionStatus {
    case processing
    case failed
    case successful
    case undefined
}

/// A type that represents customizable keys for list items in TymeX.
///
/// - Note: This enum is deprecated.  It doesn't used anymore.
@available(*, deprecated, message: " It doesn't used anymore")
public enum TymeXListItemCustomizeKeys {
    case titleLabel
    case subTitleLabel
    case contentLabel
    case leftIconImageView
    case rightIconImageView
}

/// A type that represents different view modes for TymeX lists.
///
/// - Note: This enum is deprecated. Please use `TymeXListViewModeV2` instead.
@available(*, deprecated, message: "Use 'TymeXListViewModeV2' instead.")
public enum TymeXListViewMode {
    case noBorderMode
    case borderMode
}
