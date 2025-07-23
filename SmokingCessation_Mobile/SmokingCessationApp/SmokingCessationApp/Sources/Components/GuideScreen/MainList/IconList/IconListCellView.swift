//
//  IconListCellView.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

public class IconListCellView: UIStackView {
    var guideLineContent: GuideLineContent?
    public init(iconGuidelineContent: IconGuidelineContent) {
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .leading
        spacing = 16
        setupIconListLeftView(iconImage: iconGuidelineContent.icon)
        setupContentView(iconGuidelineContent: iconGuidelineContent)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupContentView(iconGuidelineContent: IconGuidelineContent) {
        let contentViewContainer = UIView()
        let guidelineContent = GuideLineContent(
            title: iconGuidelineContent.title,
            subTitle: iconGuidelineContent.subTitle,
            isTitleHighlighted: iconGuidelineContent.isTitleHighlighted)
        contentViewContainer.translatesAutoresizingMaskIntoConstraints = false
        guidelineContent.translatesAutoresizingMaskIntoConstraints = false
        guideLineContent = guidelineContent
        contentViewContainer.addSubview(guidelineContent)
        NSLayoutConstraint.activate([
            guidelineContent.topAnchor.constraint(equalTo: contentViewContainer.topAnchor, constant: 16),
            guidelineContent.bottomAnchor.constraint(
                equalTo: contentViewContainer.bottomAnchor, constant: -16),
            guidelineContent.leadingAnchor.constraint(equalTo: contentViewContainer.leadingAnchor),
            guidelineContent.trailingAnchor.constraint(equalTo: contentViewContainer.trailingAnchor)
        ])
        addArrangedSubview(contentViewContainer)
    }

    func setupIconListLeftView(iconImage: UIImage) {
        let imageView = UIImageView(image: iconImage)
        imageView.contentMode = .scaleAspectFit
        let guidelineLeftView = GuideLineCell(
            guidelineCellType: .icon(iconImage: imageView),
            showTopLine: false,
            showBottomLine: false
        )
        guidelineLeftView.translatesAutoresizingMaskIntoConstraints = false
        guidelineLeftView.widthAnchor.constraint(
            equalToConstant: GuideScreen.ConstantsGuideScreen.stepNumberCircleSize
        ).isActive = true
        addArrangedSubview(guidelineLeftView)
    }
}
