//
//  TymeXSheetAlertViewController.swift
//  TymeXUIComponent
//
//  Created by Anh Tran on 24/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit
import RxSwift

public final class TymeXSheetAlertViewController: TymeXActionModalBaseViewController {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet private weak var iconContainerView: UIView!
    @IBOutlet private weak var pictogramLogoHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pictogramLogoTopConstraintToSuperView: NSLayoutConstraint!

    var isShowDragIndicator = true
    private let titleContent: String?
    private let subTitleContent: String?
    private let actions: [BaseButton]
    private let iconView: UIView?

    public init(
        iconView: UIView? = nil,
        titleContent: String?,
        subTitleContent: String? = nil,
        actions: [BaseButton]
    ) {
        self.iconView = iconView
        self.titleContent = titleContent
        self.subTitleContent = subTitleContent
        self.actions = actions
        super.init(nibName: Self.nibIdentifier, bundle: BundleSmokingCessationComponent.bundle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        applyModalBorderToContentView(contentView)
        setupTitleAndSubTitle()
        setupStackViewButtons()
        setupPictogramLogo()
        view.layoutIfNeeded()
    }

    private func setupTitleAndSubTitle() {
        if let title = titleContent, !title.isEmpty {
            titleLabel.attributedText = NSAttributedString(
                string: title,
                attributes: SmokingCessation.textTitleL
                    .color(.black)
                    .alignment(.center)
            )
        } else {
            titleLabel.isHidden = true
        }
        if let subTitle = subTitleContent, !subTitle.isEmpty {
            subTitleLabel.attributedText = NSAttributedString(
                string: subTitle,
                attributes: SmokingCessation.textBodyDefaultL
                    .color(.gray)
                    .alignment(.center)
            )
        } else {
            subTitleLabel.isHidden = true
        }
    }

    private func setupStackViewButtons() {
        buttonsStackView.spacing = 16
        buttonsStackView.mxRemoveAllSubviews()

        for action in actions {
            buttonsStackView.addArrangedSubview(action)
        }
    }

    private func setupPictogramLogo() {
        if let iconView = iconView {
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconContainerView.addSubview(iconView)
            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: iconContainerView.topAnchor),
                iconView.bottomAnchor.constraint(equalTo: iconContainerView.bottomAnchor),
                iconView.leadingAnchor.constraint(equalTo: iconContainerView.leadingAnchor),
                iconView.trailingAnchor.constraint(equalTo: iconContainerView.trailingAnchor)
            ])
        } else {
            pictogramLogoHeightConstraint.constant = 0
            pictogramLogoTopConstraintToSuperView.constant = 10
        }
    }

    // MARK: - ActionModalPresentable

    public override var mxShortFormHeight: TymeXActionModalHeight {
        return .contentHeight(contentView.frame.size.height)
    }
}
