//
//  TymeXSearchBar.swift
//  TymeXUIComponent
//
//  Created by Duc Nguyen on 24/5/24.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import UIKit

@IBDesignable
public class TymeXSearchBar: UIView, TymeXSearchBarDelegate {
    var cancelButtonConstraint: NSLayoutConstraint!
    var backgroundViewConstraint: NSLayoutConstraint!
    let backgroundView: UIImageView = UIImageView()
    let cancelButton: UIButton = UIButton(type: .custom)
    private lazy var leftImageView: UIImageView = makeLeftImageView()
    private lazy var leftView: UIView = makeLeftView()
    public let searchTextField: TymeXSearchTextField = TymeXSearchTextField(frame: .zero)

    // MARK: - Public Properties
    @IBInspectable
    public var showsCancelButton: Bool = true {
        didSet {
            updateLayout()
        }
    }
    @IBInspectable
    public var text: String? {
        get {
            searchTextField.text
        }
        set {
            searchTextField.text = newValue
        }
    }
    @IBInspectable
    public var placeholder: String? {
        get {
            searchTextField.placeholder
        }
        set {
            searchTextField.placeholder = newValue
        }
    }

    public var textAlignment: NSTextAlignment {
        get {
            searchTextField.textAlignment
        }
        set {
            searchTextField.textAlignment = newValue
        }
    }
    @IBInspectable
    public var isEnabled: Bool {
        get {
            searchTextField.isEnabled
        }
        set {
            searchTextField.isEnabled = newValue
        }
    }

    public var leftViewMode: UITextField.ViewMode {
        get {
            searchTextField.leftViewMode
        }
        set {
            searchTextField.leftViewMode = newValue
        }
    }

    public var clearButtonMode: UITextField.ViewMode {
        get {
            searchTextField.clearButtonMode
        }
        set {
            searchTextField.clearButtonMode = newValue
        }
    }

    public var returnKeyType: UIReturnKeyType {
        get {
            searchTextField.returnKeyType
        }
        set {
            searchTextField.returnKeyType = newValue
        }
    }

    public func setCancelButtonTitle(text: String = "Huỷ bỏ") {
        cancelButton
            .setAttributedTitle(
                NSAttributedString(
                    string: text,
                    attributes: SmokingCessation.textLabelEmphasizeS.color(SmokingCessation.colorTextDefault)
                ),
                for: .normal)
        cancelButton
            .setAttributedTitle(
                NSAttributedString(
                    string: text,
                    attributes: SmokingCessation.textLabelEmphasizeS.color(SmokingCessation.colorTextDefault.withAlphaComponent(0.75))
                ),
                for: .highlighted)
    }

    public weak var delegate: TymeXSearchBarDelegate?
    public var leftImage: UIImage? = SmokingCessation().iconSearch {
        didSet {
            leftImageView.image = leftImage
        }
    }
    // MARK: - Lifecycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - First Responder Handling
    override public var isFirstResponder: Bool {
        searchTextField.isFirstResponder
    }

    @discardableResult
    override public func resignFirstResponder() -> Bool {
        searchTextField.resignFirstResponder()
    }

    @discardableResult
    override public func becomeFirstResponder() -> Bool {
        searchTextField.becomeFirstResponder()
    }

    override public var canResignFirstResponder: Bool {
        searchTextField.canResignFirstResponder
    }

    override public var canBecomeFirstResponder: Bool {
        searchTextField.canBecomeFirstResponder
    }

    func resetTextField() {
        text = ""
        delegate?.searchBar(self, textDidChange: "")
    }

    public func cancelSearch() {
        let shouldCancel = delegate?.searchBarShouldCancel(self) ?? searchBarShouldCancel(self)
        if shouldCancel {
            resetTextField()
            searchTextField.resignFirstResponder()
        }
    }

    @objc func pressedCancelButton(_ sender: AnyObject) {
        cancelSearch()
    }
    // MARK: - Handle Text Changes
    @objc func didChangeTextField(_ textField: UITextField) {
        let newText = textField.text ?? ""
        delegate?.searchBar(self, textDidChange: newText)
    }
}

// MARK: - UITextFieldDelegate
extension TymeXSearchBar: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let shouldBegin = delegate?.searchBarShouldBeginEditing(self) ?? searchBarShouldBeginEditing(self)
        if shouldBegin {
            updateCancelButtonVisibility(makeVisible: true)
        }
        return shouldBegin
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.searchBarDidBeginEditing(self)
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let shouldEnd = delegate?.searchBarShouldEndEditing(self) ?? searchBarShouldEndEditing(self)
        if shouldEnd {
            updateCancelButtonVisibility(makeVisible: false)
        }
        return shouldEnd
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.searchBarDidEndEditing(self)
    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let delegate = delegate else {
            return searchBar(self, shouldChangeCharactersIn: range, replacementString: string)
        }
        return delegate.searchBar(self, shouldChangeCharactersIn: range, replacementString: string)
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let shouldClear = delegate?.searchBarShouldClear(self) ?? searchBarShouldClear(self)
        return shouldClear
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = delegate?.searchBarShouldReturn(self) ?? searchBarShouldReturn(self)
        return shouldReturn
    }
}

extension TymeXSearchBar {
    // MARK: - UI Updates
    private func setupViews() {
        setupAccessibility()
        self.delegate = self
        translatesAutoresizingMaskIntoConstraints = false
        setupBackgroundView()
        setupTextField()
        setupCancelButton()
        backgroundView.addSubview(searchTextField)
        addSubview(cancelButton)
        addSubview(backgroundView)
        updateLayout()
    }

    private func updateLayout() {
        let isInitialUpdate = backgroundView.constraints.isEmpty
        let isTextFieldInEditMode = cancelButtonConstraint?.isActive ?? false
        backgroundViewConstraint?.isActive = false
        cancelButtonConstraint?.isActive = false

        if isInitialUpdate {
            let constraints = [
                backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
                backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
                backgroundView.heightAnchor.constraint(equalToConstant: 48),
                searchTextField.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
                searchTextField.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
                searchTextField.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
                searchTextField.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: SmokingCessation.spacing2),
                cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                cancelButton.topAnchor.constraint(equalTo: topAnchor),
                cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
            backgroundViewConstraint = backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)
            cancelButtonConstraint = backgroundView.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor,
                                                                              constant: -SmokingCessation.spacing4)
        }
        cancelButtonConstraint.constant = -SmokingCessation.spacing4
        if isTextFieldInEditMode && !isInitialUpdate && showsCancelButton {
            cancelButtonConstraint.isActive = true
        } else {
            backgroundViewConstraint.isActive = true
        }
    }

    private func setupBackgroundView() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.isUserInteractionEnabled = true
        updateBackgroundImage(
            withRadius: SmokingCessation.cornerRadius4,
            corners: .allCorners,
            color: SmokingCessation.colorBackgroundInfoBase
        )
    }

    private func setupTextField() {
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.delegate = self
        searchTextField.autocorrectionType = .default
        searchTextField.autocapitalizationType = .none
        searchTextField.spellCheckingType = .no
        searchTextField.adjustsFontSizeToFitWidth = false
        searchTextField.clipsToBounds = true
        searchTextField.addTarget(self, action: #selector(didChangeTextField(_:)), for: .editingChanged)
        searchTextField.leftView = leftView
        searchTextField.tintColor = SmokingCessation.colorIconSelection
        searchTextField.defaultTextAttributes = SmokingCessation.textBodyDefaultL.color(SmokingCessation.colorTextDefault)
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "Tim kiem",
            attributes: SmokingCessation.textBodyDefaultL.color(SmokingCessation.colorTextSubtle)
        )
    }

    private func setupCancelButton() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.alpha = 0.0
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)
        cancelButton.reversesTitleShadowWhenHighlighted = true
        cancelButton.adjustsImageWhenHighlighted = true
        cancelButton.addTarget(self, action: #selector(pressedCancelButton(_:)), for: .touchUpInside)
        setCancelButtonTitle()
    }

    private func updateBackgroundImage(withRadius radius: CGFloat, corners: UIRectCorner, color: UIColor) {
        let insets = UIEdgeInsets(top: radius, left: radius, bottom: radius, right: radius)
        let imgSize = CGSize(width: radius * 2, height: radius * 2)
        var img = UIImage.mxImageWithSolidColor(color, size: imgSize)
        img = img.mxRoundedImage(with: radius, cornersToRound: corners)
        img = img.resizableImage(withCapInsets: insets)
        backgroundView.image = img
        backgroundColor = UIColor.clear
    }

    private func updateCancelButtonVisibility(makeVisible show: Bool) {
        if show && showsCancelButton {
            backgroundViewConstraint.isActive = false
            cancelButtonConstraint.isActive = true
        } else {
            cancelButtonConstraint.isActive = false
            backgroundViewConstraint.isActive = true
        }
        UIView.animate(
            withDuration: AnimationDuration.duration4.value,
            delay: 0,
            options: [],
            animations: {
                self.layoutIfNeeded()
                self.cancelButton.alpha = show ? 1 : 0
            }, completion: nil)
    }

    private func makeLeftImageView() -> UIImageView {
        let imageView = UIImageView(image: SmokingCessation().iconSearch)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func makeLeftView() -> UIView {
        let container = UIView()
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: SmokingCessation.spacing3,
            bottom: 0,
            trailing: SmokingCessation.spacing2)
        container.addSubview(leftImageView)
        NSLayoutConstraint.activate([
            leftImageView.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            leftImageView.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            leftImageView.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            leftImageView.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor),
            leftImageView.widthAnchor.constraint(equalToConstant: 24),
            leftImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        return container
    }
}

extension TymeXSearchBar {
    public func setupAccessibility() {
        self.accessibilityIdentifier = "\(type(of: self))"
        cancelButton.titleLabel?.accessibilityIdentifier = "cancelButtonTitleLabel\(type(of: self))"
    }
}
