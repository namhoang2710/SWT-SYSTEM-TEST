//
//  TymeXAvatar.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 19/11/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

public protocol TymeXAvatarProtocol {
    func configure(with model: TymeXAvatarModel?)
}

public class TymeXAvatar: UIView, TymeXAvatarProtocol {
    private var imgView = UIImageView()
    private var initialsLabel: UILabel?
    private var model: TymeXAvatarModel?

    private lazy var indicatorDotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var backgroundBadgeView: UIView = {
        let backgroundBadgeView = UIView()
        backgroundBadgeView.backgroundColor = SmokingCessation.primaryColor
        backgroundBadgeView.clipsToBounds = true
        backgroundBadgeView.mxAnchor(size: CGSize(width: 20, height: 20))
        backgroundBadgeView.layer.cornerRadius = 10
        return backgroundBadgeView
    }()

    private lazy var badgeView = UIView()
    private lazy var badgeImageView = makeImageView()
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?

    var accessibilityID: String?
    // Initializer
    public init(model: TymeXAvatarModel?, accessibilityID: String? = nil) {
        self.model = model
        self.accessibilityID = accessibilityID
        super.init(frame: .zero)
        setupView()
        configure(with: model)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = (model?.avatarSize.size ?? 0)/2
        backgroundColor = (model?.isCircleBackground ?? false) ? SmokingCessation.primaryColor : SmokingCessation.primaryColor
        // Remove existing constraints if any
        widthConstraint?.isActive = false
        heightConstraint?.isActive = false
        // Create new constraints
        widthConstraint = widthAnchor.constraint(equalToConstant: model?.avatarSize.size ?? 0)
        heightConstraint = heightAnchor.constraint(equalToConstant: model?.avatarSize.size ?? 0)
        NSLayoutConstraint.activate([widthConstraint!, heightConstraint!])
        setupImageView()
        setupInitialLabel()
        setupBadgeView()
    }

    public func configure(with model: TymeXAvatarModel?) {
        self.model = model
        let newSize = model?.avatarSize.size ?? 0
        widthConstraint?.constant = newSize
        heightConstraint?.constant = newSize
        layer.cornerRadius = newSize / 2
        if let avatarURL = model?.avatarURL, !avatarURL.isEmpty, let url = URL(string: avatarURL) {
            loadImageURL(url: url)
        } else if let accountName = model?.accountName, !accountName.isEmpty {
            loadInitials(accountName: accountName)
        } else if let avatarImage = model?.avatarImage {
            loadAvatarImage(image: avatarImage)
        } else if let iconImage = model?.iconImage {
            self.model?.avatarSize = .sizeL
            setupView()
            loadIconImage(image: iconImage)
        }
        if (model?.avatarSize == .sizeL || model?.type == .icon) && (model?.showIndicatorDot == true) {
            badgeView.isHidden = true
            if indicatorDotImageView.superview == nil {
                addSubview(indicatorDotImageView)
                NSLayoutConstraint.activate([
                    indicatorDotImageView.widthAnchor.constraint(equalToConstant: 14),
                    indicatorDotImageView.heightAnchor.constraint(equalToConstant: 14),
                    indicatorDotImageView.topAnchor.constraint(equalTo: self.topAnchor),
                    indicatorDotImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
                ])
            }
            if model?.indicatorDot == nil {
                indicatorDotImageView.image = UIImage(
                    named: "ic_indicator_dot",
                    in: Bundle(for: TymeXAvatar.self),
                    compatibleWith: nil)
            } else {
                indicatorDotImageView.image = model?.indicatorDot
            }
        } else {
            indicatorDotImageView.removeFromSuperview()
            configBadgeImageView()
        }
    }

    private func setupImageView() {
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imgView)
        NSLayoutConstraint.activate([
            imgView.widthAnchor.constraint(equalTo: self.widthAnchor),
            imgView.heightAnchor.constraint(equalTo: self.heightAnchor),
            imgView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imgView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    private func setupInitialLabel() {
        initialsLabel = UILabel()
        initialsLabel?.translatesAutoresizingMaskIntoConstraints = false
        guard let nameLabel = initialsLabel else { return }
        addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    private func setupBadgeView() {
        if model?.avatarSize != .sizeM {
            badgeView.addSubview(backgroundBadgeView)
            addSubview(badgeView)
            badgeView.addSubview(badgeImageView)
            badgeView.clipsToBounds = true
            badgeView.mxAnchor(size: CGSize(width: 24, height: 24))
            badgeView.layer.cornerRadius = 12
            badgeImageView.mxAnchor(size: CGSize(width: 16, height: 16))

            NSLayoutConstraint.activate([
                backgroundBadgeView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                backgroundBadgeView.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
                badgeView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 2),
                badgeView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 2),
                badgeImageView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                badgeImageView.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor)
            ])
        }
    }

    private func loadImageURL(url: URL) {
        guard let avatarSize = model?.avatarSize.size else { return }
        initialsLabel?.isHidden = true
        imgView.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .processor(ResizingImageProcessor(referenceSize: CGSize(width: avatarSize, height: avatarSize))
                           |> RoundCornerImageProcessor(cornerRadius: avatarSize/2)),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ]
        )
    }

    private func loadAvatarImage(image: UIImage?) {
        imgView.image = image
        initialsLabel?.text = ""
    }

    private func loadIconImage(image: UIImage?) {
            imgView.image = image
            initialsLabel?.text = ""
            imgView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }

    // Load image from initials
    private func loadInitials(accountName: String) {
        let initialsName = accountName.prefix(2).uppercased()
        let typographyName = getTypography(avatarSize: model?.avatarSize)
        initialsLabel?.attributedText = NSAttributedString(
            string: initialsName,
            attributes: typographyName
                .color(SmokingCessation.colorTextInverse)
                .alignment(.center)
        )
        initialsLabel?.isHidden = false
        imgView.image = nil
    }

    private func configBadgeImageView() {
        guard let badgeImage = model?.badgeImage else {
            badgeView.isHidden = true
            return
        }
        badgeView.isHidden = false
        badgeImageView.image = badgeImage
        badgeView.backgroundColor = .white
    }

    private func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func getTypography(avatarSize: TymeXAvatarSize?) -> [NSAttributedString.Key: Any] {
        switch avatarSize {
        case .sizeL:
            return SmokingCessation.textTitleM
        case .sizeM:
            return SmokingCessation.textTitleS
        case .sizeXL:
            return SmokingCessation.textTitleL
        case .none:
            return SmokingCessation.textTitleM
        }
    }
}
