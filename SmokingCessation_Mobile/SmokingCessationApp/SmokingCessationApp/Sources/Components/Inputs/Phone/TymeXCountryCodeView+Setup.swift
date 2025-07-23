//
//  TymeXCountryCodeView+Setup.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 05/03/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit


extension TymeXCountryCodeView {
    func setupStackView() {
        let stackView = createStackView()
        addSubview(stackView)
        setupConstraints(for: stackView)
    }

    private func createStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            flagImageView, codeLabel, dropdownImageView
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = SmokingCessation.spacing1
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func setupConstraints(for stackView: UIStackView) {
        NSLayoutConstraint.activate([
            flagImageView.widthAnchor.constraint(equalToConstant: 24),
            flagImageView.heightAnchor.constraint(equalToConstant: 24),
            dropdownImageView.widthAnchor.constraint(equalToConstant: 16),
            dropdownImageView.heightAnchor.constraint(equalToConstant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
}
