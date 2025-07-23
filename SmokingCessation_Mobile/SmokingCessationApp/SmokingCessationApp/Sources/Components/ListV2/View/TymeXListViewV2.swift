//
//  TymeXListView.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 11/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit
import RxSwift
import Lottie
public protocol TymeXListViewV2Delegate: AnyObject {
    func listView(_ listView: TymeXListViewV2, headerViewForSection section: Int) -> UIView?
}

open class TymeXListViewV2: TymeXBaseView, UIGestureRecognizerDelegate {
    // MARK: - IBOutlets
    @IBOutlet weak private(set) var tableView: UITableView!
    @IBOutlet weak private var topTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak private var leadingTableViewConstraint: NSLayoutConstraint!
    public weak var delegate: TymeXListViewV2Delegate?

    // MARK: - Properties
    var model: TymeXListModelV2?
    var items: [TymeXListItemModelV2] = []
    var multipleSectionItems: [[TymeXListItemModelV2]] = []
    var listViewMode: TymeXListViewModeV2 = .borderMode
    var isConfiguredTableView: Bool = false
    var isFirstSwipeCell: Bool = false
    let disposeBag = DisposeBag()

    public var didSelectItem: ((Int, TymeXListItemModelV2) -> Void)?
    public var buttonActionCallback: (() -> Void)?
    // To support multiple sections data
    public var didSelectIndexPath: ((IndexPath) -> Void)?
    public var didSelectLeadingContentButton: ((TymeXListItemModelV2, UITableViewCell, IndexPath) -> Void)?
    public var didSelectTrailingCheckbox: ((TymeXListItemModelV2, UITableViewCell, IndexPath) -> Void)?
    public var didSelectTrailingToggle: ((TymeXListItemModelV2, UITableViewCell, IndexPath) -> Void)?
    public var didFavouriteItem: ((TymeXListItemModelV2?, UITableViewCell) -> Void)?
    public var willDisplayItem: ((TymeXListItemModelV2?, UITableViewCell) -> Void)?
    public var didChangeHeightOfListView: ((Double) -> Void)?

    public var isScrollEnabled: Bool = false {
        didSet {
            tableView.isScrollEnabled = isScrollEnabled
        }
    }

    public var isAllowsSelection: Bool = true {
        didSet {
            tableView.allowsSelection = isAllowsSelection
        }
    }

    var heightOfListView: CGFloat {
        guard let model = model else { return 0.0 }
        return model.getHeightOfListView(tableView: tableView)
    }

    open override func commonInit() {
        super.commonInit()
        configTableView()
    }
}

// MARK: - Configurations
extension TymeXListViewV2 {
    func configContainerView() {
        contentView.backgroundColor = (self.model?.shouldClearBackgroundColor ?? false) ? .clear : SmokingCessation.colorBackgroundDefault
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
        switch listViewMode {
        case .borderMode:
            contentView.layer.cornerRadius = listViewMode.getCornerRadius()
            contentView.mxBorderColor = listViewMode.getBorderColor()
            contentView.mxBorderWidth = listViewMode.getBorderWidth()
        case .noBorderMode:
            contentView.layer.cornerRadius = 0.0
            contentView.mxBorderColor = .clear
            contentView.mxBorderWidth = 0.0
            leadingTableViewConstraint.constant = 0.0
        }
        topTableViewConstraint.constant = (self.model?.shouldIncludeTopPadding ?? false)
            ? TymeXListItemModel.topPadding : 0
        layoutSubviews()
    }

    func createTymeXListStandardCell(
        indexPath: IndexPath,
        tableView: UITableView ) -> UITableViewCell {
            let itemsLength = multipleSectionItems[safeIndex: indexPath.section]?.count ?? 0
            let isLastIndex = (indexPath.row == (itemsLength - 1))
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TymeXListStandardCell.reuseId,
                for: indexPath) as? TymeXListStandardCell,
                  let item = multipleSectionItems[safeIndex: indexPath.section]?[safeIndex: indexPath.row]
            else { return UITableViewCell() }
            cell.bind(
                item,
                isLastIndex: isLastIndex,
                currentIndex: indexPath
            )

            // register tap action
            cell.onTapCell = { [weak self] model, indexPath in
                guard let self = self else { return }
                self.didSelectItem?(indexPath.row, model)
                self.didSelectIndexPath?(indexPath)
            }
            cell.onUpdateLayouts = {
                tableView.beginUpdates()
                tableView.endUpdates()
            }

            // on tap on leadingContentButton
            cell.onTapLeadingContentButton = { [weak self] model, indexPath in
                guard let self = self else { return }
                self.didSelectLeadingContentButton?(model, cell, indexPath)
            }

            cell.onTapTrailingCheckbox = { [weak self] model, indexPath in
                guard let self = self else { return }
                self.didSelectTrailingCheckbox?(model, cell, indexPath)
            }

            cell.onTapTrailingToggle = { [weak self] model, indexPath in
                guard let self = self else { return }
                self.didSelectTrailingToggle?(model, cell, indexPath)
            }

            // play animation easing for 1st item which was allowed to perform swipe action
            if indexPath.row == getAllowedIndex(indexPath: indexPath) {
                item.isAllowToPlayHintAnimation = true
                playHintAnimation(cell: cell)
            }
        return cell
    }

    func createTymeXListInforCell(
        indexPath: IndexPath,
        tableView: UITableView ) -> UITableViewCell {
            let itemsLength = multipleSectionItems[safeIndex: indexPath.section]?.count ?? 0
            let isLastIndex = (indexPath.row == (itemsLength - 1))
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TymeXListInfoCell.reuseId,
                for: indexPath) as? TymeXListInfoCell
            else { return UITableViewCell() }
            guard let itemModel = multipleSectionItems[safeIndex: indexPath.section]?[safeIndex: indexPath.row] else {
                return UITableViewCell()
            }
            cell.bind(itemModel, isLastIndex: isLastIndex, currentIndex: indexPath)

            // register tap action
            cell.onTapCell = { [weak self] model in
                guard let self = self else { return }
                self.didSelectItem?(indexPath.row, model)
                self.didSelectIndexPath?(indexPath)
            }

            // register callback for actionButton
            cell.actionTextCallback = { [weak self] in
                guard let self = self else { return }
                buttonActionCallback?()
            }
        return cell
    }
}

// MARK: - Helper Methods
extension TymeXListViewV2 {
    func updateCellTransform(
        for cell: TymeXListStandardCell,
        with translationX: Double,
        halfCellWidth: CGFloat) {
        DispatchQueue.main.async {
            let transformX = abs(translationX) <= halfCellWidth ? translationX : -halfCellWidth
            cell.transform = CGAffineTransform(translationX: transformX, y: 0)
        }
    }

    func calculateSwipeProgress(translationX: Double, threadholdSwipeWidth: CGFloat) -> CGFloat {
        return min(max(0, -translationX / threadholdSwipeWidth), 1)
    }

    func resetCellPosition(for cell: TymeXListStandardCell, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = .identity
            }, completion: { isCompleted in
                if isCompleted {
                    completion?()
                }
            })
        }
    }

    func updateFavorite(for cell: TymeXListStandardCell) {
        cell.updateTrailingModel()
        updateFavoriteForSwipeActionView(cell: cell)
        didFavouriteItem?(cell.model, cell)

        // Reset right padding for lineView
        cell.updateLineViewConstraints(newTrailingConstant: -SmokingCessation.spacing4)

        cell.setNeedsLayout()
        cell.layoutIfNeeded()
    }

    func updateFavoriteForSwipeActionView(cell: TymeXListStandardCell) {
        let isFavorite = cell.model?.trailingStatus?.isFavorite() ?? false
        cell.swipeActionView.isFavorite = isFavorite
        cell.swipeActionView.updateTitle(title: isFavorite ? "Unfavorite" : "Favorite")
    }

    private func getAllowedIndex(indexPath: IndexPath) -> Int {
        guard let items = self.multipleSectionItems[safeIndex: indexPath.section]
        else { return 1 }
        for (index, model) in items.enumerated() where model.isAllowToSwipe {
            return index
        }
        return -1
    }
}
