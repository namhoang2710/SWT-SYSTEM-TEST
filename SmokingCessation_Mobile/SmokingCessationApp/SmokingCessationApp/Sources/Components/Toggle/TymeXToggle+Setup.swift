//
//  TymeXToggle+Setup.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 26/02/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit
extension TymeXToggle {
    func setupView() {
        self.backgroundColor = inactiveColor
        self.translatesAutoresizingMaskIntoConstraints = false
        toggleCircle.backgroundColor = thumbColor
        toggleCircle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(toggleCircle)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleTapped))
        self.addGestureRecognizer(tapGesture)
        setupToggleConstraints()
        setupToggleCircleConstraints()
    }

    private func setupToggleCircleConstraints() {
        toggleCircleLeadingConstraint = toggleCircle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2)
        NSLayoutConstraint.activate([
            toggleCircle.widthAnchor.constraint(equalTo: self.heightAnchor, constant: -SmokingCessation.spacing1),
            toggleCircle.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -SmokingCessation.spacing1),
            toggleCircle.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            toggleCircleLeadingConstraint
        ])
    }

    private func setupToggleConstraints() {
        self.removeWidthHeightContraints()
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: self.defaultWidth),
            self.heightAnchor.constraint(equalToConstant: self.defaultHeight)
        ])
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        // make sure toggleCircle & self have cornerRadius exactly
        self.layer.cornerRadius = getCornerRadiusBase()
        toggleCircle.layer.cornerRadius = toggleCircle.bounds.height / 2

        // call it here to make sure self.frame.width returning correct value instead of zero
        updateToggleAppearance()
    }
}
