//
//  TymeXListItemCell.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 23/11/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit
import Lottie

public class TymeXListStandardCell: TymeXListBaseCell {

    var model: TymeXListItemModelV2?
    var isFirstIndex: Bool = false
    var isLastIndex: Bool = false
    var currentIndex: IndexPath = IndexPath(index: -1)

    // MARK: - SubViews
    // For Leading
    lazy var leadingTitle = makeLabel()
    lazy var leadingSubTitle1 = makeLabel()
    lazy var leadingsubTitle2 = makeLabel()
    lazy var leadingAddOnStatus = makeLabel()
    var leadingAddOnButton: BaseButton?

    // For Trailing
    lazy var trailingTitle = makeLabel()
    lazy var trailingSubTitle1 = makeLabel()
    lazy var trailingSubTitle2 = makeLabel()
    lazy var trailingAmount = makeLabel()

    // Views
    let lineView = UIView()
    var leadingView: UIView?
    var trailingView: UIView?
    let swipeActionView: TymeXSwipeActionView = {
        let view = TymeXSwipeActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // constraints
    private var lineViewTrailingConstraint: NSLayoutConstraint?

    // stackViews
    lazy var stackViewMain = makeStackView(
        axis: .horizontal, spacing: SmokingCessation.spacing4,
        clipsToBounds: false
    )
    lazy var stackViewLeading = makeStackView()
    lazy var stackViewLeadingContent = makeStackView(alignment: .leading)
    lazy var stackViewTrailingContent = makeStackView(alignment: .trailing)
    lazy var stackViewTrailing = makeStackView(alignment: .trailing, clipsToBounds: false)

    var maxIntrinsicWidthLeadingContent: CGFloat = 0
    var maxIntrinsicWidthTrailingContent: CGFloat = 0
    let spacingItems = SmokingCessation.spacing4
    var widthTrailingContentConstraint: NSLayoutConstraint?

    // Actions
    public var onTapCell: ((TymeXListItemModelV2, IndexPath) -> Void)?
    public var onUpdateLayouts: (() -> Void)?
    public var onTapLeadingContentButton: ((TymeXListItemModelV2, IndexPath) -> Void)?
    public var onTapTrailingCheckbox: ((TymeXListItemModelV2, IndexPath) -> Void)?
    public var onTapTrailingIcon: ((TymeXListItemModelV2, IndexPath) -> Void)?
    public var onTapTrailingToggle: ((TymeXListItemModelV2, IndexPath) -> Void)?

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

        // leading
        leadingView = nil
        leadingTitle.text = ""
        leadingSubTitle1.text = ""
        leadingsubTitle2.text = ""
        leadingAddOnStatus.text = ""
        leadingAddOnButton = nil

        // trailing
        trailingTitle.text = ""
        trailingSubTitle1.text = ""
        trailingSubTitle2.text = ""
        trailingAmount.text = ""
        trailingView = nil

        // remove all gestures recognizer
        if let gestureRecognizers = self.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers where !(gestureRecognizer is UITapGestureRecognizer) {
                self.removeGestureRecognizer(gestureRecognizer)
            }
        }
    }

    // MARK: - SetupView
    private func setupView() {
        setupStackViewMain()
        setupLineView()
        setupSwipeActionView()
        configActions()
    }

    private func setupStackViewMain() {
        contentView.addSubview(stackViewMain)
        stackViewMain.translatesAutoresizingMaskIntoConstraints = false
        stackViewMain.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate([
            stackViewMain.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacingItems),
            stackViewMain.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: spacingItems),
            stackViewMain.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacingItems),
            stackViewMain.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -spacingItems)
        ])
        stackViewMain.distribution = .fill
        stackViewMain.alignment = .firstBaseline
    }

    private func setupLineView() {
        lineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lineView)

        lineViewTrailingConstraint = lineView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -SmokingCessation.spacing4
        )

        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: SmokingCessation.spacing4
            ),
            lineViewTrailingConstraint!,
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func setupSwipeActionView() {
        // Set constraints for swipeActionView
        contentView.addSubview(swipeActionView)
        NSLayoutConstraint.activate([
            swipeActionView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
            swipeActionView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            swipeActionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            swipeActionView.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])

        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        // Initially position the favoriteActionView off-screen to the right
        hideSwipeActionView()
    }

    private func configActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnView(_:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }

    @objc func handleTapOnView(_ sender: UITapGestureRecognizer) {
        guard let model = self.model else { return }

        // Check if trailingView is a TymeXCheckbox
        if let checkbox = trailingView as? Checkbox {
            let trailingStatus = model.trailingStatus

            // Use an if statement to handle the checkbox case
            if case .checkbox(let isChecked) = trailingStatus {
                // Toggle the checkbox state
                let newTrailingStatus = TymeXTrailingStatus.checkbox(!isChecked)
                model.trailingStatus = newTrailingStatus
                checkbox.isChecked = !isChecked

                // Call the closure if it's set
                self.onTapTrailingCheckbox?(model, self.currentIndex)
            }
        } else {
            // Call the onTapCell closure if it's set
            onTapCell?(model, currentIndex)
        }
    }

    func updateLineViewConstraints(newTrailingConstant: CGFloat) {
        // Deactivate old constraint
        lineViewTrailingConstraint?.isActive = false

        // Update new constraint
        lineViewTrailingConstraint = lineView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: newTrailingConstant
        )

        // Active new constraint
        NSLayoutConstraint.activate([
            lineViewTrailingConstraint!
        ])

        // Update layout immediately
        lineView.layoutIfNeeded()
    }

    func hideSwipeActionView() {
        // Move the action view off-screen to the right
        swipeActionView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width / 2, y: 0)
    }

    func updateTrailingModel(
        status: TymeXTrailingStatus = .favoriteAnimation(TymeXSwipeActionState.redHeart.rawValue)
    ) {
        if let itemModel = model {
            let isOldFavoriteStatus = self.model?.trailingStatus?.isFavorite() ?? false
            itemModel.trailingStatus = isOldFavoriteStatus ? nil : status
            updateTrailing()
//            bind(itemModel, isLastIndex: isLastIndex)
        }
    }

    @objc func handleTappedOnLeadingContentButton() {
        guard let model = self.model else { return }
        onTapLeadingContentButton?(model, currentIndex)
    }

    public override func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // If view's touch is TymeXBaseButton, not trigger this gesture
        if let view = touch.view, view is BaseButton {
            return false
        }
        return true
    }
}

extension TymeXListStandardCell {
    func makeLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeStackView(
        alignment: UIStackView.Alignment = .leading,
        axis: NSLayoutConstraint.Axis = .vertical,
        spacing: Double = SmokingCessation.spacing1,
        clipsToBounds: Bool = true) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.clipsToBounds = clipsToBounds
        return stackView
    }
}

extension TymeXListStandardCell: ClassIdentifiable {}
