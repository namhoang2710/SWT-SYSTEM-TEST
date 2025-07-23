//
//  TymeXListViewV2+Public.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 20/01/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXListViewV2 {
    // MARK: - Public methods
    public func configuration(
        with model: TymeXListModelV2
    ) {
        self.model = model
        self.items = model.items
        if !items.isEmpty {
            multipleSectionItems.removeAll()
            multipleSectionItems.append(items)
        } else {
            self.multipleSectionItems = model.multipleSectionItems
        }
        self.listViewMode = model.listViewMode
        configContainerView()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self,
                  !self.multipleSectionItems.isEmpty,
                  !self.multipleSectionItems[0].isEmpty
            else { return }
            self.tableView.scrollToRow(
                at: IndexPath(row: 0, section: 0),
                at: .top,
                animated: true
            )
        }
    }

    public func updateItems(newItems: [TymeXListItemModelV2]) {
        items = newItems
        model?.items = newItems
        if !items.isEmpty {
            multipleSectionItems.removeAll()
            multipleSectionItems.append(items)
        }
        reloadData()
    }

    public func updateMultipleItems(newItems: [[TymeXListItemModelV2]]) {
        multipleSectionItems = newItems
        model?.multipleSectionItems = newItems
        if !items.isEmpty {
            multipleSectionItems.removeAll()
            multipleSectionItems.append(items)
        }
        reloadData()
    }

    public func getListItems() -> [TymeXListItemModelV2] {
        return self.items
    }

    public func getTableView() -> UITableView {
        return tableView
    }

    public func reloadData() {
        self.tableView.reloadData()
    }

    public func updateBorderColor(newBorderColor: UIColor) {
        contentView.mxBorderColor = newBorderColor
    }
}
