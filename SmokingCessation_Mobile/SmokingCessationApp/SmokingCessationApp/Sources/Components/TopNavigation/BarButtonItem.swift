//
//  BarButtonItem.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import UIKit

final class BarButtonItem: UIBarButtonItem {
    private var actionHandler: TymeXCompletion?

    convenience init(
        image: UIImage?,
        style: UIBarButtonItem.Style,
        actionHandler: TymeXCompletion?
    ) {
        self.init(
            image: image,
            style: style,
            target: nil,
            action: #selector(barButtonItemPressed(_:))
        )
        target = self
        self.actionHandler = actionHandler
    }

    convenience init(
        title: String?,
        style: UIBarButtonItem.Style,
        actionHandler: TymeXCompletion?
    ) {
        self.init(
            title: title,
            style: style,
            target: nil,
            action: #selector(barButtonItemPressed(_:))
        )
        target = self
        self.actionHandler = actionHandler
    }

    convenience init(
        barButtonSystemItem systemItem: UIBarButtonItem.SystemItem,
        actionHandler: TymeXCompletion?
    ) {
        self.init(
            barButtonSystemItem: systemItem,
            target: nil,
            action: #selector(barButtonItemPressed(_:))
        )
        target = self
        self.actionHandler = actionHandler
    }

    convenience init(
        customView: UIView,
        actionHandler: TymeXCompletion?
    ) {
        self.init(customView: customView)
        target = self
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(barButtonItemPressed))
        self.customView?.addGestureRecognizer(tapGesture)
        if let contentView = self.customView {
            for subview in contentView.subviews {
                subview.addGestureRecognizer(tapGesture)
            }
        }
        self.actionHandler = actionHandler
    }

    @objc private func barButtonItemPressed(_ sender: Any) {
        actionHandler?()
    }
}
