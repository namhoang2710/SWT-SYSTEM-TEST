//
//  ActionSheetResultViewController.swift
//  TymeXUIComponent
//
//  Created by Anh Tran on 23/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit
import RxSwift

public final class TymeXSheetOutcomeViewController: TymeXActionModalBaseViewController {

    @IBOutlet weak var paddingHeightContentView: NSLayoutConstraint!
    @IBOutlet weak var pictogramLogoHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var buttonsStackView: UIStackView!

    var iconView: UIView?
    private let titleContent: String?
    private let subTitleContent: String?
    private let actions: [BaseButton]

    var isShowDragIndicator = true

    public init(
        iconView: UIView?,
        titleContent: String? = nil,
        subTitleContent: String? = nil,
        actions: [BaseButton]
    ) {
        self.iconView = iconView
        self.titleContent = titleContent
        self.subTitleContent = subTitleContent
        self.actions = actions
        super.init(nibName: Self.nibIdentifier, bundle: BundleSmokingCessation.bundle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyModalBorderToContentView(contentView)
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
        }

        if let title = titleContent {
            titleLabel.attributedText = NSAttributedString(
                string: title,
                attributes: SmokingCessation.textDisplayM.paragraphStyle(lineSpacing: 4, alignment: .center)
                    .color(.black)
            )
        } else {
            titleLabel.isHidden = true
        }

        if let subTitle = subTitleContent {
            descLabel.attributedText = NSAttributedString(
                string: subTitle,
                attributes: SmokingCessation.textBodyDefaultL
                    .color(.gray)
                    .alignment(.center)
            )
        } else {
            descLabel.isHidden = true
        }

        buttonsStackView.spacing = 16
        buttonsStackView.mxRemoveAllSubviews()

        for action in actions {
            buttonsStackView.addArrangedSubview(action)
        }
        self.view.layoutIfNeeded()
    }

// MARK: - ActionModalPresentable
    public override var mxShortFormHeight: TymeXActionModalHeight {
        return .contentHeight(contentView.frame.size.height)
    }
}
