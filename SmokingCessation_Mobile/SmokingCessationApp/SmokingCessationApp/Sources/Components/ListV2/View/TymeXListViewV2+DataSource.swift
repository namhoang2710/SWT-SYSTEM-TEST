//
//  TymeXListViewV2+DataSource.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 02/01/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UITableViewDataSource
extension TymeXListViewV2: UITableViewDataSource {
    func configTableView() {
        if !isConfiguredTableView {
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .none
            tableView.separatorColor = .clear
            tableView.allowsSelection = false
            tableView.showsVerticalScrollIndicator = false
            tableView.allowsMultipleSelection = false
            tableView.dataSource = self
            tableView.delegate = self
            tableView.isScrollEnabled = true

            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = UITableView.automaticDimension
            tableView.rx.observe(CGSize.self, "contentSize")
                .filter({ $0 != nil })
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.didChangeHeightOfListView?(self.heightOfListView)
                }).disposed(by: disposeBag)
            tableView.register(cellType: TymeXListStandardCell.self)
            tableView.register(cellType: TymeXListInfoCell.self)
            isConfiguredTableView = true
        }
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return multipleSectionItems.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return multipleSectionItems[safeIndex: section]?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let itemModel = multipleSectionItems[safeIndex: indexPath.section]?[safeIndex: indexPath.row] else {
            return UITableViewCell()
        }
        switch itemModel.listType {
        case .standard:
            return createTymeXListStandardCell(
                indexPath: indexPath,
                tableView: tableView
            )
        case .infor:
            return createTymeXListInforCell(
                indexPath: indexPath,
                tableView: tableView
            )
        }
    }

    // MARK: - Gesture Recognizer for Swipe Actions
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let model = multipleSectionItems[safeIndex: indexPath.section]?[safeIndex: indexPath.row] else { return }
        willDisplayItem?(model, cell)

        if !model.isAllowToSwipe {
            return
        }

        // Add Gesture Recognizer
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        // Set the delegate
        swipeGesture.delegate = self
        cell.addGestureRecognizer(swipeGesture)
    }

    @objc func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        guard let cell = gesture.view as? TymeXListStandardCell else { return }
        guard let itemModelV2 = cell.model else { return }

        // check here to avoid the case reusable cells
        if !itemModelV2.isAllowToSwipe {
            return
        }
        let paddingRightLineView: CGFloat = 100.0
        let translation = gesture.translation(in: cell)
        let isSwipeHorizontal = isSwipeHorizontal(gestureRecognizer: gesture)
        cell.updateLineViewConstraints(newTrailingConstant: paddingRightLineView)
        if isSwipeHorizontal && gesture.state == .began {
            // update lottieName based on whether there's favorite status or not
            updateFavoriteForSwipeActionView(cell: cell)
            isFirstSwipeCell = true
        }

        // Handle swipe left
        if gesture.state == .changed, translation.x < 0 {
            self.handleSwiftLeftGesture(translationX: translation.x, for: cell)
        }

        if gesture.state == .ended || gesture.state == .cancelled {
            // Trigger handleEndGesture only for horizontal swipes
            let isHorizontalSwipe = abs(translation.x) > abs(translation.y) && translation.x < 0
            if isHorizontalSwipe {
                self.handleEndGesture(translationX: translation.x, for: cell)
            } else {
                // Reset position
                resetCellPosition(for: cell, completion: nil)
            }
            cell.updateLineViewConstraints(newTrailingConstant: paddingRightLineView)
        }
    }
}

// MARK: - UITableViewDelegate
extension TymeXListViewV2: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return delegate?.listView(self, headerViewForSection: section)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let headerView = delegate?.listView(self, headerViewForSection: section) {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            return height
        }
        return 0.0
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}
