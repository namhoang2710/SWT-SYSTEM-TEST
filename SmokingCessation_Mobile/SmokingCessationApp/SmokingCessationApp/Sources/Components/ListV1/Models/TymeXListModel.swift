//
//  TymeXListModel.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 22/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

/// A model that represents a list of items for TymeX.
///
/// - Note: This struct is deprecated. Please use `TymeXListModelV2` instead.
@available(*, deprecated, message: "Use 'TymeXListModelV2' instead.")
public struct TymeXListModel {
    public let listViewMode: TymeXListViewMode
    public var items: [TymeXListItemModel] = []
    public var shouldIncludeTopPadding: Bool = false

    /**
    Define properties for TymeXListModel
     */
    public init(
        listViewMode: TymeXListViewMode = .noBorderMode,
        shouldIncludeTopPadding: Bool = false,
        items: [TymeXListItemModel]
    ) {
        self.listViewMode = listViewMode
        self.shouldIncludeTopPadding = shouldIncludeTopPadding
        self.items = items
    }
}

extension TymeXListModel {
    public func getHeightOfListView(tableView: UITableView) -> CGFloat {
        var height: CGFloat = 0.0
        height += tableView.contentSize.height
        if shouldIncludeTopPadding {
            height += (2 * TymeXListItemModel.topPadding)
        }
        return height
    }
}
