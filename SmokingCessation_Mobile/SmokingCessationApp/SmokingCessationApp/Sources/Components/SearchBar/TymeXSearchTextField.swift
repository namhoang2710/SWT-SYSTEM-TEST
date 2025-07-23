//
//  TymeXSearchTextField.swift
//  TymeXUIComponent
//
//  Created by Duc Nguyen on 24/5/24.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public class TymeXSearchTextField: UITextField {

    private let customClearView = UIImageView()

    public override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        customUI()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
        customUI()
    }

    // MARK: - Overrides
    public override func caretRect(for position: UITextPosition) -> CGRect {
        let rect = super.caretRect(for: position)
        return CGRect(
            x: rect.origin.x,
            y: rect.origin.y,
            width: rect.width,
            height: 24
        )
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rectForBounds(rect, originalBounds: bounds)
    }

    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var spacing = 0.0
        if self.isEditing {
            spacing = 1.0
        }
        let rect = super.placeholderRect(forBounds: bounds)
        return CGRect(x: rect.origin.x + spacing, y: rect.origin.y, width: rect.width, height: rect.height)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rectForBounds(rect, originalBounds: bounds)
    }

    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let originX = bounds.size.width - 16 - SmokingCessation.spacing3
        let originY = (bounds.size.height - 16)/2
        return CGRect(
            x: originX,
            y: originY,
            width: 16,
            height: 16
        )
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if let clearButton = getClearButton() {
            clearButton.imageView?.contentMode = .scaleAspectFit
            clearButton.tintColor = SmokingCessation.colorIconDefault
            clearButton.setImage(SmokingCessation().iconCancelFilled, for: .normal)
            clearButton.accessibilityIdentifier = "Clear text button"
        }
    }

}

extension TymeXSearchTextField {
    private func rectForBounds(_ bounds: CGRect, originalBounds: CGRect) -> CGRect {
        var minX: CGFloat = 0
        var width: CGFloat = 0
        (minX, width) = if bounds.width == originalBounds.width {
            // no left and no right view
            (SmokingCessation.spacing3, bounds.width - SmokingCessation.spacing3 * 2)
        } else if bounds.minX > 0 && bounds.width == originalBounds.width - bounds.minX {
            // only left view
            (bounds.minX, bounds.width - SmokingCessation.spacing3)
        } else if bounds.minX == 0 && bounds.width < originalBounds.width {
            // only right view
            (SmokingCessation.spacing3, bounds.width - SmokingCessation.spacing3)
        } else {
            // left & right view
            (bounds.minX, bounds.width - SmokingCessation.spacing2)
        }
        return CGRect(x: minX, y: 0.0, width: width, height: bounds.height)
    }

    private func customUI() {
        leftViewMode = .always
        clearButtonMode = .whileEditing
        setupClearButtonAnimation()
        customClearView.contentMode = .scaleAspectFit
        customClearView.image = SmokingCessation().iconCancelFilled
        customClearView.alpha = 0
        addSubview(customClearView)
    }

    private func setupClearButtonAnimation() {
        addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        addTarget(self, action: #selector(textFieldEditingDidEnd), for: .editingDidEnd)
    }

    @objc private func textFieldEditingChanged() {
        if let text = text, text.length > 0 {
            animateClearButton()
        } else {
            animateClearView()
        }
    }

    @objc private func textFieldEditingDidEnd() {
        customClearView.alpha = 0
    }

    private func animateClearButton() {
        guard let clearButton = getClearButton() else { return }
        UIView.animate(withDuration: AnimationDuration.duration1.value) {
            clearButton.transform = CGAffineTransform(translationX: -SmokingCessation.spacing8, y: 0)
        } completion: { _ in
            self.customClearView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }

    private func animateClearView() {
        guard let clearButton = getClearButton() else { return }
        customClearView.frame = clearButton.frame
        customClearView.alpha = 1
        UIView.animate(withDuration: AnimationDuration.duration2.value) {
            self.customClearView.transform = CGAffineTransform(translationX: SmokingCessation.spacing8, y: 0)
        } completion: { _ in
            clearButton.transform = CGAffineTransform(translationX: SmokingCessation.spacing8, y: 0)
            self.customClearView.alpha = 0
        }
    }

    private func getClearButton() -> UIButton? {
        return value(forKey: "_clearButton") as? UIButton
    }
}

extension TymeXSearchTextField {
    public func setupAccessibility() {
        self.accessibilityIdentifier = "\(type(of: self))"
    }
}
