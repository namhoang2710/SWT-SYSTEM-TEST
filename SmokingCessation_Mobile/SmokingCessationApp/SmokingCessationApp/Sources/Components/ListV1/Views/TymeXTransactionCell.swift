//
//  TymeXTransactionCell.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 11/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

extension TymeXTransactionCell: ClassIdentifiable {}

public class TymeXTransactionCell: UITableViewCell {

    // MARK: - SubViews
    let lineView = UIView()
    let titleLabel = UILabel()
    let subTitleLabel = UILabel()
    let contentLabel = UILabel()
    let leftIconImageView = UIImageView()
    let rightIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var titlesStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = SmokingCessation.spacing1
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)
        return stackView
    }()

    lazy var rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = SmokingCessation.spacing1
        stackView.addArrangedSubview(contentLabel)
        stackView.addArrangedSubview(rightIconImageView)
        return stackView
    }()

    // MARK: - Properties
    var model: TymeXListItemModel?
    private var isLastIndex: Bool = false
    public var onTapCell: ((TymeXListItemModel) -> Void)?

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
        [leftIconImageView, titlesStackView, rightStackView, lineView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        titleLabel.numberOfLines = 0
        subTitleLabel.numberOfLines = 0
        contentLabel.numberOfLines = 0
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentLabel.setContentHuggingPriority(.required, for: .horizontal)
        leftIconImageView.contentMode = .scaleAspectFit
    }

    private func layoutView() {
        NSLayoutConstraint.activate([
            leftIconImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: SmokingCessation.spacing4
            ),
            leftIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftIconImageView.widthAnchor.constraint(equalToConstant: 24),
            leftIconImageView.heightAnchor.constraint(equalToConstant: 24),

            titlesStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: SmokingCessation.spacing4
            ),
            titlesStackView.leadingAnchor.constraint(
                equalTo: leftIconImageView.trailingAnchor,
                constant: SmokingCessation.spacing2
            ),
            titlesStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: rightStackView.leadingAnchor,
                constant: -SmokingCessation.spacing3
            ),
            titlesStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -SmokingCessation.spacing4
            ),
            rightStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -SmokingCessation.spacing4
            ),
            rightStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            lineView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: SmokingCessation.spacing4
            ),
            lineView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -SmokingCessation.spacing4
            ),
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    // MARK: - Configuration
    private func configUIs() {
        configTitleLabel()
        configSubTitleLabel()
        configContentLabel()
        configLeftIconImageView()
        configRightIconImageView()
        configLineView()
        configActions()
    }

    public func configTitleLabel() {
        guard let model = model else { return }
        titleLabel.attributedText = NSAttributedString(
            string: model.title,
            attributes: SmokingCessation.textBodyDefaultM.color(model.titleColor)
        )
        titleLabel.lineBreakMode = .byTruncatingTail
    }

    private func configSubTitleLabel() {
        guard let model = model else { return }
        let subTitle = model.subTitle
        if !subTitle.isEmpty {
            let subTitleAttribute = NSAttributedString(
                string: subTitle,
                attributes: SmokingCessation.textBodyDefaultM
                    .color(model.subTitleColor)
                    .alignment(.left)
            )
            subTitleLabel.attributedText = subTitleAttribute
            subTitleLabel.lineBreakMode = .byTruncatingTail
        }
    }

    private func configContentLabel() {
        guard let model = model else { return }
        let content = model.content ?? ""
        let contentAttribute = NSMutableAttributedString(
            string: content,
            attributes: SmokingCessation.textTitleM.color(model.contentColor).alignment(.right)
        )

        if model.transactionStatus == .failed {
            contentAttribute.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSRange(location: 2, length: content.count - 2)
            )
        }

        contentLabel.attributedText = contentAttribute
        contentLabel.lineBreakMode = .byWordWrapping
    }

    private func configLeftIconImageView() {
        guard let model = model else { return }
        var tintLeftIconColor: UIColor?
        let customizeColors = model.customizeColors
        if !customizeColors.isEmpty {
            for colorAttribute in customizeColors
            where colorAttribute.key == .leftIconImageView {
                tintLeftIconColor = colorAttribute.value
            }
        }
        let leftIcon = model.leftIcon
        if tintLeftIconColor != nil {
            leftIconImageView.image = leftIcon?.withRenderingMode(.alwaysTemplate)
            leftIconImageView.tintColor = tintLeftIconColor
        } else {
            leftIconImageView.image = leftIcon
        }
    }

    private func configRightIconImageView() {
        guard let model = model else { return }
        var tintRightIconColor: UIColor?
        let customizeColors = model.customizeColors
        if !customizeColors.isEmpty {
            for colorAttribute in customizeColors
            where colorAttribute.key == .rightIconImageView {
                tintRightIconColor = colorAttribute.value
            }
        }
        let rightIcon =
        model.rightIcon != nil ? model.rightIcon : SmokingCessation().iconChevronRight
        if tintRightIconColor != nil {
            rightIconImageView.image = rightIcon?.withRenderingMode(.alwaysTemplate)
            rightIconImageView.tintColor = tintRightIconColor
        } else {
            rightIconImageView.image = rightIcon
        }
    }

    private func configLineView() {
        lineView.isHidden = isLastIndex
        lineView.backgroundColor = SmokingCessation.colorDividerDividerBase
    }

    private func configActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnView(_:)))
        addGestureRecognizer(tapGesture)
    }

    func updateUI() {
        // For Transaction List & Item Value
        subTitleLabel.isHidden = model?.subTitle.isEmpty ?? true
        contentLabel.isHidden = false
        rightIconImageView.isHidden = true

        // Should call this function to update layout for all subViews with a new Model
        // when having a new content was updated for label's attributedText
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    @objc private func handleTapOnView(_ sender: UITapGestureRecognizer) {
        guard let model = self.model else { return }
        onTapCell?(model)
    }

    // MARK: - Binding
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
