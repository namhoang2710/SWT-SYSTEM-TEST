//
//  TymeXButtonTypeStatus.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 05/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation

public enum TymeXContentAddOnButton {
    case primary(String)
    case secondary(String)
    case tertiaryContained(String)
    case tertiaryOutlined(String)

    var title: String {
        switch self {
        case .primary(let title):
            return title
        case .secondary(let title):
            return title
        case .tertiaryContained(let title):
            return title
        case .tertiaryOutlined(let title):
            return title
        }
    }

    func makeButton() -> BaseButton {
        var button: BaseButton = PrimaryButton()
        switch self {
        case .primary(let title):
            button.setTitle(with: .text(title))
        case .secondary(let title):
            button = SecondaryButton()
            button.setTitle(with: .text(title))
        case .tertiaryContained(let title):
            button = TertiaryContainedButton()
            button.setTitle(with: .text(title))
        case .tertiaryOutlined(let title):
            button = TertiaryOutlinedButton()
            button.setTitle(with: .text(title))
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setShowLoadingForTouchUpInside(false)
        return button
    }
}
