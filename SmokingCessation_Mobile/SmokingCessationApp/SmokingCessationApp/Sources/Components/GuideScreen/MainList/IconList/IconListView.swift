//
//  IconListView.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//


import UIKit

public class IconListView: UIView {
    var iconListContent: [IconGuidelineContent]
    var iconListCellView: [IconListCellView] = []
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public init(iconListContent: [IconGuidelineContent]) {
        self.iconListContent = iconListContent
        super.init(frame: .zero)
        setupStackView()
        configureIconList()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupStackView() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func configureIconList() {
        for content in iconListContent {
            let cell = IconListCellView(iconGuidelineContent: content)
            iconListCellView.append(cell)
            stackView.addArrangedSubview(cell)
        }
    }

}
