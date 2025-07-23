//
//  TymeXNumericKeyPad+Setup.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 15/01/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXNumericKeyPad {
    func setupView() {
        // adding accessibity function set up for automation
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: SmokingCessation.spacing4),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: SmokingCessation.spacing4),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -SmokingCessation.spacing4),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -SmokingCessation.spacing4)
        ])

        setupKeys()
        self.backgroundColor = .clear
    }

    private func setupKeys() {
        keys.forEach { row in
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .equalSpacing
            stackView.addArrangedSubview(rowStackView)

            row.forEach { keyType in
                let button = createButton(for: keyType)
                rowStackView.addArrangedSubview(button)
            }
        }
    }

    private func createButton(for keyType: TymeXKeyType) -> TymeXNumericButton {
        let button = TymeXNumericButton(type: .system)
        button.keyType = keyType
        configureButton(button, forKey: keyType)
        button.setTitleColor(SmokingCessation.colorTextDefault, for: .normal)
        button.tintColor = SmokingCessation.colorTextDefault
        button.layer.cornerRadius = widthNumber / 2
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(keyReleased(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: widthNumber),
            button.heightAnchor.constraint(equalTo: button.widthAnchor)
        ])
        button.accessibilityIdentifier = "TymeXKeyType_\(keyType.getAccessibilityIdentifier())"

        // Store reference to biometric button
        if keyType == .faceID || keyType == .touchID {
            biometricButton = button
        }
        return button
    }

    private func configureButton(_ button: TymeXNumericButton, forKey key: TymeXKeyType) {
        switch key {
        case .number(let value):
            createLabelNumber(button: button, value: value)
        case .delete:
            button.addImage(SmokingCessation().iconMinus)
        case .faceID:
            button.addImage(SmokingCessation().iconWithdrawInverse)
        case .touchID:
            button.addImage(SmokingCessation().iconArrowRightInverse)
        case .none:
            button.alpha = 0
        }
    }

    private func createLabelNumber(button: UIButton, value: String) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "labelNumber\(type(of: self))"
        let attributes = SmokingCessation.textLabelEmphasizeXl
            .alignment(.center).color(SmokingCessation.colorTextDefault)
        let attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        label.attributedText = attributedString
        button.addSubview(label)

        label.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
    }
}
