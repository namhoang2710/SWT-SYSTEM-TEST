//
//  TymeXListInfo.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 13/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public class TymeXListInfoCell: TymeXListBaseCell {
    lazy var stackViewMain = makeStackView(axis: .horizontal, spacing: SmokingCessation.spacing4)
    lazy var stackViewLeadingContent = makeStackView(alignment: .leading)
    lazy var stackViewTrailingContent = makeStackView(alignment: .leading)

    // For Leading
    lazy var leadingTitle = makeLabel()

    // For Trailing
    lazy var trailingTitle = makeLabel()
    lazy var trailingSubTitle1 = makeLabel()
    lazy var trailingSubTitle2 = makeLabel()
    lazy var actionText: UILabel = {
        let button = UILabel()
        button.numberOfLines = 0
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // LineView
    let lineView = UIView()

    let spacingItems = SmokingCessation.spacing4
    var model: TymeXListItemModelV2?
    var isFirstIndex: Bool = false
    var isLastIndex: Bool = false
    var currentIndex: IndexPath = IndexPath(index: -1)
    var maxIntrinsicWidthLeadingContent: CGFloat = 0
    var maxIntrinsicWidthTrailingContent: CGFloat = 0

    // Actions
    public var onTapCell: ((TymeXListItemModelV2) -> Void)?
    public var actionTextCallback: (() -> Void)?

    // MARK: - Init
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateMainStacksLayouts()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        leadingTitle.text = ""
        trailingTitle.text = ""
        trailingSubTitle1.text = ""
        trailingSubTitle2.text = ""
    }
}

extension TymeXListInfoCell {
    func makeLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeStackView(
        alignment: UIStackView.Alignment = .leading,
        axis: NSLayoutConstraint.Axis = .vertical,
        spacing: Double = SmokingCessation.spacing1) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}

extension TymeXListInfoCell: ClassIdentifiable {}
