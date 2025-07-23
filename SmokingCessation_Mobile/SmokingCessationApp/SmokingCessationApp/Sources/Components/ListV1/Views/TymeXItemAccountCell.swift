//
//  TymeXItemAccountCell.swift
//  TymeXUIComponent
//
//  Created by Duc Nguyen on 8/6/24.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

public final class TymeXItemAccountCell: UITableViewCell {

    // MARK: - SubViews
    let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()

    private lazy var titleLabel = makeLabel()
    private lazy var subTitleLabel = makeLabel()
    private lazy var contentLabel = makeLabel()
    private lazy var leftIconView = makeImageView()
    private lazy var badgeImageView = makeImageView()
    private lazy var badgeView = UIView()
    private lazy var avatarLabel = makeLabel()
    private lazy var leftContentView = makeImageView()
    private lazy var rightStackView = makeStackView(alignment: .trailing)
    private lazy var titleStackView = makeStackView(alignment: .leading)

    let rightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.setImage(UIImage(
            named: "ic_heart",
            in: BundleSmokingCessationComponent.bundle,
            compatibleWith: nil
        ), for: .normal)
        button.setImage(UIImage(
            named: "ic_heart_filled",
            in: BundleSmokingCessationComponent.bundle,
            compatibleWith: nil
        ), for: .selected)
        return button
    }()

    // MARK: - Properties
    private var model: TymeXListItemModel?
    public var index: Int = 0
    private var isLastIndex: Bool = false
    public var onTapCell: ((TymeXListItemModel) -> Void)?
    public var onChangeFavouriteModel: ((TymeXListItemModel) -> Void)?

    // MARK: - Init
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        layoutView()
    }

    // MARK: - SetupView
    private func setupView() {
        titleLabel.numberOfLines = 0
        subTitleLabel.numberOfLines = 0
        contentLabel.numberOfLines = 0
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subTitleLabel.setContentHuggingPriority(.required, for: .vertical)
        subTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentLabel.setContentHuggingPriority(.required, for: .horizontal)
        rightButton.setContentHuggingPriority(.required, for: .horizontal)
        rightButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentView.addSubview(leftContentView)
        contentView.addSubview(titleStackView)
        contentView.addSubview(rightStackView)
        contentView.addSubview(lineView)
        leftContentView.addSubview(leftIconView)
        leftContentView.addSubview(badgeView)
        badgeView.addSubview(badgeImageView)
        leftContentView.addSubview(avatarLabel)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
        rightStackView.addArrangedSubview(contentLabel)
        rightStackView.addArrangedSubview(rightButton)
        rightStackView.spacing = SmokingCessation.spacing1
    }

    private func layoutView() {
        leftContentView.mxAnchor(size: CGSize(width: 44, height: 44))
        leftIconView.mxAnchor(size: CGSize(width: 24, height: 24))
        badgeImageView.mxAnchor(size: CGSize(width: 16, height: 16))
        badgeView.mxAnchor(size: CGSize(width: 20, height: 20))
        NSLayoutConstraint.activate([
            leftContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: SmokingCessation.spacing4),
            leftContentView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            titleStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: SmokingCessation.spacing4),
            titleStackView.leadingAnchor.constraint(
                equalTo: leftContentView.trailingAnchor,
                constant: SmokingCessation.spacing2
            ),
            titleStackView.trailingAnchor.constraint(
                equalTo: rightStackView.leadingAnchor,
                constant: -SmokingCessation.spacing3
            ),
            titleStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -SmokingCessation.spacing4
            ),
            rightStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -SmokingCessation.spacing4
            ),
            rightStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: SmokingCessation.spacing4),
            lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -SmokingCessation.spacing4),
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            badgeView.trailingAnchor.constraint(equalTo: leftContentView.trailingAnchor, constant: 2),
            badgeView.bottomAnchor.constraint(equalTo: leftContentView.bottomAnchor, constant: 2),
            badgeImageView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            badgeImageView.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            leftIconView.centerXAnchor.constraint(equalTo: leftContentView.centerXAnchor),
            leftIconView.centerYAnchor.constraint(equalTo: leftContentView.centerYAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: leftContentView.centerYAnchor),
            avatarLabel.leadingAnchor.constraint(equalTo: leftIconView.leadingAnchor),
            avatarLabel.trailingAnchor.constraint(equalTo: leftIconView.trailingAnchor)
        ])
    }

    func updateUI() {
        // Should call this function to update layout for all subViews with a new Model
        // when having a new content was updated for label's attributedText
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
}

// MARK: - Binding
extension TymeXItemAccountCell {
    public func bind(
        _ model: TymeXListItemModel,
        isLastIndex: Bool
    ) {
        self.model = model
        self.isLastIndex = isLastIndex
        configUIs()
        updateUI()
    }
}

// MARK: - Configuration
extension TymeXItemAccountCell {
    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    private func makeStackView(alignment: UIStackView.Alignment) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = SmokingCessation.spacing1
        stackView.alignment = alignment
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func configUIs() {
        configLineView()
        configTitleLabel()
        configSubTitleLabel()
        configContentLabel()
        configLeftIconImageView()
        configActions()
        configRightButton()
        configBadgeImageView()
    }

    private func configTitleLabel() {
        guard let model = model else { return }
        let titleAttribute = NSAttributedString(
            string: model.title,
            attributes: SmokingCessation.textBodyDefaultL
                .color(model.titleColor)
                .alignment(.left)
        )
        titleLabel.attributedText = titleAttribute
        titleLabel.lineBreakMode = .byTruncatingTail
    }

    private func configContentLabel() {
        guard let model = model, let content = model.content else {
            contentLabel.isHidden = true
            return
        }
        contentLabel.isHidden = content.isEmpty

        let contentAttribute = NSMutableAttributedString(
            string: content,
            attributes: SmokingCessation.textBodyDefaultM
                .color(model.contentColor)
                .alignment(.right)
        )
        contentLabel.attributedText = contentAttribute
        contentLabel.lineBreakMode = .byWordWrapping
    }

    private func configSubTitleLabel() {
        guard let model = model else { return }
        let subTitle = model.subTitle
        subTitleLabel.isHidden = subTitle.isEmpty
        let subTitleAttribute = NSAttributedString(
            string: subTitle,
            attributes: SmokingCessation.textBodyDefaultM
                .color(model.subTitleColor)
                .alignment(.left)
        )
        subTitleLabel.attributedText = subTitleAttribute
    }

    private func configLeftIconImageView() {
        leftContentView.backgroundColor = SmokingCessation.colorBackgroundInfoBase
        leftContentView.layer.cornerRadius = 22
        guard let model = model else { return }
        if let avatarURL = model.avatarURL, let url = URL(string: avatarURL) {
            leftContentView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .processor(ResizingImageProcessor(referenceSize: CGSize(width: 44, height: 44))
                               |> RoundCornerImageProcessor(cornerRadius: 22)),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ]
            )
            leftIconView.image = nil
            avatarLabel.text = ""
        } else if let accountName = model.accountName {
            let initialsName = accountName.getInitialsName()
            avatarLabel.attributedText = NSAttributedString(
                string: initialsName,
                attributes: SmokingCessation.textTitleM
                    .color(SmokingCessation.colorTextDefault)
                    .alignment(.center)
            )
            leftContentView.image = nil
            leftIconView.image = nil
        } else {
            leftIconView.image = model.leftIcon
            avatarLabel.text = ""
            leftContentView.image = nil
        }
    }

    private func configLineView() {
        lineView.isHidden = isLastIndex
        lineView.backgroundColor = SmokingCessation.colorDividerDividerBase
    }

    private func configRightButton() {
        rightButton.addTarget(self, action: #selector(onRightButtonClicked), for: .touchUpInside)
        updateFavourite()
    }

    public func updateFavourite() {
        guard let model = model, let isFavourite = model.isFavourite else {
            rightButton.isHidden = true
            return
        }
        rightButton.isHidden = false
        rightButton.isSelected = isFavourite
    }

    @objc private func handleTapOnView(_ sender: UITapGestureRecognizer) {
        guard let model = self.model else { return }
        onTapCell?(model)
    }

    private func configActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnView(_:)))
        addGestureRecognizer(tapGesture)
    }
    private func configBadgeImageView() {
        guard let badgeImage = model?.badgeImage else {
            badgeView.isHidden = true
            return
        }
        badgeView.isHidden = false
        badgeImageView.image = badgeImage
        badgeImageView.layer.cornerRadius = 8
        badgeView.layer.cornerRadius = 10
        badgeView.backgroundColor = SmokingCessation.colorBackgroundPrimaryBase
    }

    @objc private func onRightButtonClicked() {
        guard let model = model, let onChangeFavouriteModel = onChangeFavouriteModel else { return }
        onChangeFavouriteModel(model)
    }
}

extension TymeXItemAccountCell: ClassIdentifiable {}
