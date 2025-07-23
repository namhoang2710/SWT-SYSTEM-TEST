//
//  TymeXListView.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 11/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit
import RxSwift

/// A view that displays a list of items.
///
/// - Note: This class is deprecated. Please use `TymeXListViewV2` instead.
@available(*, deprecated, message: "Use 'TymeXListViewV2' instead.")
open class TymeXListView: TymeXBaseView {
    // MARK: - IBOutlets
    @IBOutlet weak private(set) var tableView: UITableView!
    @IBOutlet weak private var topTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak private var leadingTableViewConstraint: NSLayoutConstraint!

    // MARK: - Properties
    private var model: TymeXListModel?
    private var items: [TymeXListItemModel] = []
    private var listViewMode: TymeXListViewMode = .borderMode
    private var isConfiguredTableView: Bool = false
    let disposeBag = DisposeBag()

    public var didSelectItem: ((Int, TymeXListItemModel) -> Void)?
    public var willDisplayItem: ((IndexPath) -> Void)?
    public var didChangeFavouriteItem: ((Int, TymeXListItemModel) -> Void)?
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

    private var heightOfListView: CGFloat {
        guard let model = model else { return 0.0 }
        return model.getHeightOfListView(tableView: tableView)
    }

    // MARK: - Public methods
    public func configuration(
        with model: TymeXListModel
    ) {
        self.model = model
        self.items = model.items
        self.listViewMode = model.listViewMode
        configTableView()
        configContainerView()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self,
                  !self.items.isEmpty
            else { return }
            self.tableView.scrollToRow(
                at: IndexPath(row: 0, section: 0),
                at: .top,
                animated: true
            )
        }
    }

    public func updateItems(newItems: [TymeXListItemModel]) {
        items = newItems
        reloadData()
    }

    public func getListItems() -> [TymeXListItemModel] {
        return self.items
    }

    public func getTableView() -> UITableView {
        return tableView
    }

    public func reloadData() {
        self.tableView.reloadData()
    }
}

// MARK: - Configurations
extension TymeXListView {
    private func configTableView() {
        if !isConfiguredTableView {
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .none
            tableView.separatorColor = .clear
            tableView.allowsSelection = true
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

            tableView.register(cellType: TymeXTransactionCell.self)
            tableView.register(cellType: TymeXItemValueCell.self)
            tableView.register(cellType: TymeXItemNavigationalCell.self)
            tableView.register(cellType: TymeXItemAccountCell.self)
            tableView.register(cellType: TymeXListStandardCell.self)
            tableView.register(cellType: TymeXListInfoCell.self)
            isConfiguredTableView = true
        }
    }

    private func configContainerView() {
        contentView.backgroundColor = TymeXListItemModel.backgroundColor
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
        switch listViewMode {
        case .borderMode:
            contentView.layer.cornerRadius = TymeXListItemModel.cornerRadius
            contentView.mxBorderColor = TymeXListItemModel(
                listType: self.items.first?.listType ?? .transactionList
            ).borderColor
            contentView.mxBorderWidth = TymeXListItemModel(
                listType: self.items.first?.listType ?? .transactionList
            ).borderWidth
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

    private func createTymeXTransactionCell(
        indexPath: IndexPath,
        tableView: UITableView
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TymeXTransactionCell.reuseId,
            for: indexPath) as? TymeXTransactionCell
        else { return UITableViewCell() }
        cell.bind(
            items[indexPath.row],
            isLastIndex: (indexPath.row >= (items.count - 1))
        )
        cell.onTapCell = { [weak self] model in
            guard let self = self else { return }
            self.didSelectItem?(indexPath.row, model)
        }

        return cell
    }

    private func createTymeXItemValueCell(
        indexPath: IndexPath,
        tableView: UITableView
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TymeXItemValueCell.reuseId,
            for: indexPath) as? TymeXItemValueCell
        else { return UITableViewCell() }
        cell.bind(
            items[indexPath.row],
            isLastIndex: (indexPath.row >= (items.count - 1))
        )
        cell.onTapCell = { [weak self] model in
            guard let self = self else { return }
            self.didSelectItem?(indexPath.row, model)
        }
        return cell
    }

    private func createTymeXItemNavigationalCell(
        indexPath: IndexPath,
        tableView: UITableView
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TymeXItemNavigationalCell.reuseId,
            for: indexPath) as? TymeXItemNavigationalCell
        else { return UITableViewCell() }
        cell.bind(
            items[indexPath.row],
            isLastIndex: (indexPath.row >= (items.count - 1))
        )
        cell.onTapCell = { [weak self] model in
            guard let self = self else { return }
            self.didSelectItem?(indexPath.row, model)
        }
        return cell
    }

    private func createTymeXItemAccountCell(
        indexPath: IndexPath,
        tableView: UITableView
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TymeXItemAccountCell.reuseId,
            for: indexPath) as? TymeXItemAccountCell
        else { return UITableViewCell() }
        cell.bind(
            items[indexPath.row],
            isLastIndex: (indexPath.row >= (items.count - 1))
        )
        cell.onTapCell = { [weak self] model in
            guard let self = self else { return }
            self.didSelectItem?(indexPath.row, model)
        }
        cell.onChangeFavouriteModel = { [weak self] model in
            guard let self = self else { return }
            self.updateFavoriteModel(index: indexPath.row, model: model)
            self.didChangeFavouriteItem?(indexPath.row, items[indexPath.row])
        }
        return cell
    }

    private func updateFavoriteModel(index: Int, model: TymeXListItemModel) {
        var newItems = [TymeXListItemModel]()
        for (idx, item) in items.enumerated() {
            if idx == index {
                var newItem = model
                if let isFavourite = model.isFavourite {
                    newItem.updateIsFavourite(to: !isFavourite)
                    print(" newItem.isFavourite = \(String(describing: newItem.isFavourite)) \n")
                }
                newItems.append(newItem)
            } else {
                newItems.append(item)
            }
        }
        self.items = newItems
        reloadData()
    }
}

// MARK: - UITableViewDelegate
extension TymeXListView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .zero
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension TymeXListView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        willDisplayItem?(indexPath)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemModel = items[indexPath.row]
        switch itemModel.listType {
        case .transactionList:
            return createTymeXTransactionCell(
                indexPath: indexPath,
                tableView: tableView
            )
        case .itemList:
            return createTymeXItemValueCell(
                indexPath: indexPath,
                tableView: tableView
            )
        case .navigationalList:
            return createTymeXItemNavigationalCell(
                indexPath: indexPath,
                tableView: tableView
            )
        case .accountList:
            return createTymeXItemAccountCell(
                indexPath: indexPath,
                tableView: tableView
            )
        }
    }
}
