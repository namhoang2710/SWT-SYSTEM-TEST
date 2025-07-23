//
//  NavigationTitleViewStyle.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import UIKit

public enum NavigationTitleViewStyle: Equatable {
    case byDefault(title: String)
    case twoLines(title: String, subTitle: String)
    case multiLines(attributed: NSMutableAttributedString)
    case onlyIcon(image: UIImage?)
    case progressBar(currentProgress: Float, maxProgress: Float)
    case empty
}

extension NavigationTitleViewStyle {
    func makeTitleView(
        heightNaviBar: CGFloat,
        maxWidthOfBarButtons: CGFloat,
        mode: NavigationMode
    ) -> UIView? {
        switch self {
        case .byDefault(let title):
            return makeTileLabel(
                title: title,
                heightNaviBar: heightNaviBar,
                maxWidthOfBarButton: maxWidthOfBarButtons,
                mode: mode
            )
        case .twoLines(let title, let subTitle):
            return makeTilteView(
                title: title,
                subTitle: subTitle,
                heightNaviBar: heightNaviBar,
                maxWidthOfBarButton: maxWidthOfBarButtons,
                mode: mode
            )
        case .multiLines( let attribute):
            return makeTitleLabel(
                attribute: attribute,
                heightNaviBar: heightNaviBar,
                maxWidthOfBarButton: maxWidthOfBarButtons
            )
        case .onlyIcon(let image):
            return makeImageView(image: image)
        case .progressBar(let currentProgress, let maxProgress):
            return makeProgress(currentProgress: currentProgress, maxProgress: maxProgress)
        case .empty:
            return nil
        }
    }
}

// MARK: - Supports
extension NavigationTitleViewStyle {
    private func makeTileLabel(
        title: String,
        heightNaviBar: CGFloat,
        maxWidthOfBarButton: CGFloat,
        mode: NavigationMode
    ) -> UIView {
        let widthOfTitleView = calculateMaxWidth(maxWidthOfBarButton)
        let sizeOfTitleView = CGSize(width: widthOfTitleView, height: heightNaviBar)
        let titleView = UIView(frame: CGRect(origin: .zero, size: sizeOfTitleView))
        let titleLabel = UILabel(frame: CGRect(origin: .zero, size: sizeOfTitleView))
        titleLabel.numberOfLines = 1
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: SmokingCessation.textLabelEmphasizeM
                .color(mode.textColor)
                .paragraphStyle(
                    lineSpacing: 24,
                    lineBreakMode: .byTruncatingTail,
                    alignment: .center
                )
        )
        titleLabel.accessibilityIdentifier = "titleLabel\(type(of: self))"
        titleView.addSubview(titleLabel)
        return titleView
    }

    private func makeTilteView(
        title: String,
        subTitle: String,
        heightNaviBar: CGFloat,
        maxWidthOfBarButton: CGFloat,
        mode: NavigationMode
    ) -> UIView {
        let widthOfTitleView = calculateMaxWidth(maxWidthOfBarButton)
        let titleView = UIView(frame: CGRect(
            origin: .zero,
            size: CGSize(width: widthOfTitleView, height: heightNaviBar))
        )

        let titleLabel = UILabel(frame: CGRect(
            origin: .zero,
            size: CGSize(width: widthOfTitleView, height: 24))
        )
        titleLabel.numberOfLines = 1
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: SmokingCessation.textLabelEmphasizeM
                .color(mode.textColor)
                .paragraphStyle(
                    lineSpacing: 24,
                    lineBreakMode: .byTruncatingTail,
                    alignment: .center
                )
        )
        titleLabel.accessibilityIdentifier = "titleLabel\(type(of: self))"
        titleView.addSubview(titleLabel)

        let subTitleLabel = UILabel(frame: CGRect(
            origin: CGPoint(x: 0, y: 24),
            size: CGSize(width: widthOfTitleView, height: 20))
        )
        subTitleLabel.numberOfLines = 1
        subTitleLabel.attributedText = NSAttributedString(
            string: subTitle,
            attributes: SmokingCessation.textLabelDefaultS
                .color(mode.textColor)
                .paragraphStyle(
                    lineSpacing: 20,
                    lineBreakMode: .byTruncatingTail,
                    alignment: .center)
        )
        subTitleLabel.accessibilityIdentifier = "subTitleLabel\(type(of: self))"
        titleView.addSubview(subTitleLabel)

        return titleView
    }

    private func makeImageView(
        image: UIImage?
    ) -> UIImageView {
        guard let image = image else { return UIImageView() }
        let imageSize = image.size
        let imageFrame = CGRect(origin: .zero, size: imageSize)
        let imageView = UIImageView(frame: imageFrame)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.accessibilityIdentifier = "imageView\(type(of: self))"
        return imageView
    }

    private func makeTitleLabel(
        attribute: NSMutableAttributedString,
        heightNaviBar: CGFloat,
        maxWidthOfBarButton: CGFloat
    ) -> UILabel {
        let widthOfTitleView = calculateMaxWidth(maxWidthOfBarButton)
        let titleLabel = UILabel(
            frame: CGRect(x: 0, y: 0, width: widthOfTitleView, height: heightNaviBar)
        )
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = attribute
        titleLabel.accessibilityIdentifier = "titleLabel\(type(of: self))"
        return titleLabel
    }

    private func calculateMaxWidth(
        _ maxWidthOfBarButton: CGFloat
    ) -> CGFloat {
        return UIScreen.main.bounds.width - (2 * (16 + maxWidthOfBarButton))
    }

    func makeProgress(currentProgress: Float, maxProgress: Float) -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false

        // Set up Auto Layout for progressView
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 200),
            progressView.heightAnchor.constraint(equalToConstant: 6)
        ])
        progressView.setProgress(currentProgress/maxProgress, animated: true)
        progressView.layer.cornerRadius = 3
        progressView.layer.masksToBounds = true
        progressView.trackTintColor = .white.withAlphaComponent(0.8)
        progressView.tintColor = .accent
        progressView.accessibilityIdentifier = "progressView\(type(of: self))"

        return progressView
    }
}
