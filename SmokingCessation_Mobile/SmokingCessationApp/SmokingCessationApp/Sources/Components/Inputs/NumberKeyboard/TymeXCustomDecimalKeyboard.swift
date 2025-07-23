//
//  CustomDecimalKeyboard.swift
//  TymeXUIComponent
//
//  Created by Thao Lai on 14/03/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public class TymeXCustomDecimalKeyboard: UIView {
    public weak var delegate: CustomDecimalKeyboardDelegate?
    private(set) var decimalSymbol: String = "" {
        didSet {
            initializeKeyboard()
        }
    }
    private let deleteSymbol = "⌫"
    private var keys: [[String]] {
        [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            [decimalSymbol, "0", deleteSymbol]
        ]
    }

    // Define the title color, background color, and border color
    var titleColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }

    var buttonBackgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? UIColor.tertiaryLabel : UIColor.white
        } else {
            return UIColor.white
        }
    }

    var keyboardHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let threshold: CGFloat = 736
        return screenHeight <= threshold ? 216 : 291
    }

    public override var intrinsicContentSize: CGSize {
         return CGSize(width: UIView.noIntrinsicMetric, height: keyboardHeight)
     }

    private func initializeKeyboard() {
        subviews.forEach { $0.removeFromSuperview() }
        let keyboard = setupKeyboard()
        keys.forEach { rowKeys in
            let row = createRow(keys: rowKeys)
            keyboard.addArrangedSubview(row)
        }
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        if #available(iOS 13.0, *) {
            backgroundColor =  isDarkMode ? UIColor.systemGray3 : UIColor.systemGray4
        } else {
            backgroundColor = UIColor.lightGray
        }
    }

    private func setupKeyboard() -> UIStackView {
        let keyboard = UIStackView()
        keyboard.axis = .vertical
        keyboard.distribution = .fillEqually
        keyboard.spacing = SmokingCessation.spacing2
        self.addSubview(keyboard)
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        let padding: CGFloat = SmokingCessation.spacing2
        NSLayoutConstraint.activate([
            keyboard.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            keyboard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            keyboard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
        return keyboard
    }

    private func createRow(keys: [String]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = SmokingCessation.spacing1
        keys.forEach { key in
            let button = createButton(with: key)
            row.addArrangedSubview(button)
        }
        return row
    }

    private func createButton(with title: String) -> UIButton {
        let button = UIButton()
        let shouldHideBorder = title == decimalSymbol || title == deleteSymbol
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 26)
        button.setTitleColor(titleColor, for: .normal)
        button.layer.cornerRadius = SmokingCessation.spacing2
        button.backgroundColor = shouldHideBorder ? .clear : buttonBackgroundColor
        button.accessibilityIdentifier = "TymeXCustomDecimalKeyboard_Keys_\(title)"
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 1
        button.layer.shadowOpacity = 0.1
        button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
        return button
    }

    @objc private func keyPressed(_ sender: UIButton) {
        guard let key = sender.title(for: .normal),
              let textField = delegate,
              let selectedRange = textField.selectedTextRange else {
            return
        }

        let location = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
        let length = textField.offset(from: selectedRange.start, to: selectedRange.end)
        let nsRange = NSRange(location: location, length: length)

        if key == deleteSymbol {
            textField.handleCustomeKeyboardDeleteKey()
        } else {
            guard textField.shouldChangeCharacters(
                in: nsRange,
                replacementString: key
            ) else { return }
            textField.insertText(key)
        }
    }

    public func setDecimalSymbol(decimalSymbol: String) {
        self.decimalSymbol = decimalSymbol
    }
}


