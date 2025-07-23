//
//  TymeXListModel.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 22/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public struct TymeXListModelV2 {
    public let listViewMode: TymeXListViewModeV2
    public var items: [TymeXListItemModelV2] = []
    public var multipleSectionItems: [[TymeXListItemModelV2]] = []
    public var shouldIncludeTopPadding: Bool = false
    public var shouldClearBackgroundColor: Bool = false

    /**
    Define properties for TymeXListModel
     */
    public init(
        listViewMode: TymeXListViewModeV2 = .noBorderMode,
        shouldIncludeTopPadding: Bool = false,
        shouldClearBackgroundColor: Bool = false,
        items: [TymeXListItemModelV2] = [],
        multipleSectionItems: [[TymeXListItemModelV2]] = []
    ) {
        self.listViewMode = listViewMode
        self.shouldIncludeTopPadding = shouldIncludeTopPadding
        self.shouldClearBackgroundColor = shouldClearBackgroundColor
        self.items = items
        self.multipleSectionItems = multipleSectionItems
    }
}

extension TymeXListModelV2 {
    public func getHeightOfListView(tableView: UITableView) -> CGFloat {
        var height: CGFloat = 0.0
        if self.items.isEmpty && self.multipleSectionItems.isEmpty {
            return height
        }
        var extraHeaderHeight: CGFloat = 0
        // There is an un-expected space when use grouped tableView
        if tableView.numberOfSections > 1 {
            extraHeaderHeight = 35
        } else {
            extraHeaderHeight = 20
        }
        height += tableView.contentSize.height - extraHeaderHeight
        if shouldIncludeTopPadding {
            height += (2 * TymeXListItemModelV2.topPadding)
        }
        return height
    }
}
