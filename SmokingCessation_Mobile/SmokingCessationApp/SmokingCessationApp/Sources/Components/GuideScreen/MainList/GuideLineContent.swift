//
//  GuideLineContent.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

public class GuideLineContent: UIStackView {
    let titleLabel: PaddedUILabel = {
        let label = PaddedUILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.accessibilityIdentifier = "guideLineTitleLabelTymeXGuideScreen"
        return label
    }()

    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.accessibilityIdentifier = "guideLineSubtitleTymeXGuideScreen"
        return label
    }()

    public init(title: String, subTitle: String?, isTitleHighlighted: Bool) {
        super.init(frame: .zero)
        axis = .vertical
        alignment = .fill
        spacing = 4
        setupGuideLineContent(title: title, subTitle: subTitle, isTitleHighlighted: isTitleHighlighted)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupGuideLineContent(title: String, subTitle: String?, isTitleHighlighted: Bool) {
        // setup title
        addArrangedSubview(titleLabel)
        let highLightTitleLabelStyle = SmokingCessation.textTitleM.color(.black).alignment(.left)
        let defaultTitleLabelStyle = SmokingCessation.textBodyDefaultL.color(.black).alignment(.left)
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: isTitleHighlighted ? highLightTitleLabelStyle : defaultTitleLabelStyle)
        // setup subtitle
        if let subTitle = subTitle, !subTitle.isEmpty {
            addArrangedSubview(subTitleLabel)
            subTitleLabel.attributedText = NSAttributedString(
                string: subTitle, attributes: SmokingCessation.textBodyDefaultM.color(.gray)
            )
        }
    }
}
