//
//  TymeXListInfoCell+Setup.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 07/02/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXListInfoCell {
    // MARK: - SetupView
    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        setupStackViewMain()
        setupLineView()
        configActions()
    }

    func setupStackViewMain() {
        contentView.addSubview(stackViewMain)
        stackViewMain.translatesAutoresizingMaskIntoConstraints = false
        stackViewMain.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate([
            stackViewMain.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacingItems),
            stackViewMain.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: spacingItems),
            stackViewMain.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacingItems),
            stackViewMain.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -spacingItems)
        ])
        stackViewMain.addArrangedSubview(stackViewLeadingContent)
        stackViewMain.addArrangedSubview(stackViewTrailingContent)
        stackViewMain.distribution = .fill
        stackViewMain.alignment = .firstBaseline
    }

    private func setupLineView() {
        lineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lineView)
        NSLayoutConstraint.activate([
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

    func configActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnView(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc func handleTapOnView(_ sender: UITapGestureRecognizer) {
        guard let model = self.model else { return }
        onTapCell?(model)
    }
}
