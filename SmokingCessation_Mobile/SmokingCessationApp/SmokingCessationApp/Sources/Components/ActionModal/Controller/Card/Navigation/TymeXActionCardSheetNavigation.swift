//
//  ActionCardSheetNavigation.swift
//  TymeComponent
//
//  Created by Tuan Pham on 20/04/2022.
//

import UIKit

public class TymeXActionCardSheetNavigation: UIView {

    private var containerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
//        label.style(stylist: LabelStylist.headlineSemiBold(textColor: UIColor.white))
        return label
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .green

        addSubview(containerView)
        containerView.mxFillSuperview()

        addSubview(titleLabel)
        titleLabel.mxFillSuperview()
    }

    func configure(_ config: AppearanceConfiguration) {
        backgroundColor = config.backgroundColor
        titleLabel.textColor = config.tintColor
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

extension TymeXActionCardSheetNavigation {

    public struct AppearanceConfiguration {
        let backgroundColor: UIColor
        let tintColor: UIColor
    }
}
