//
//  TymeXBaseInputView.swift
//  TymeComponent
//
//  Created by Tuan Tran on 20/09/2021.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public class TymeXBaseInputView: UIView {

    // MARK: Views
    private lazy var contentView = makeContentView()
    private lazy var headerContentView = makeHeaderContentView()
    private lazy var underLineView = makeUnderLineView()
    private lazy var underFocusedLineView = makeUnderFocusedLineView()
    private lazy var underErrorLineView = makeUnderErrorLineView()

    lazy var helperView = TymeXInputHelperContentView()
    lazy var middleContentView = makeMiddleContentView()

    private var underHighlightedLineWidthConstraint: NSLayoutConstraint?
    private var underLineAnimator: UIViewPropertyAnimator?

    // MARK: properties
    var textAlignment: NSTextAlignment {
        return .center
    }
    var isTyping: Bool {
        return false
    }

    public var inputState: TymeXInputState = .loseFocus {
        didSet {
            if inputState != oldValue {
                inputStateChanged()
            }
        }
    }

    public var msgDefault = TymeXInputHelperMessage()
    var temptMsg: String?
    var inputTitleLabel: String?

    // MARK: setup Views
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupContentViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        setupContentViews()
    }

    func getPlaceHolderAttributedString(
        _ str: String,
        isEmptyText: Bool,
        isFocus: Bool = false
    ) -> NSAttributedString {
        return NSAttributedString(
            string: str,
            attributes: inputState.getPlaceHolderTypography(
                isEmptyText: isEmptyText,
                isFocus: isFocus,
                alignment: textAlignment
            )
        )
    }

    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        layoutMargins = UIEdgeInsets(top: SmokingCessation.spacing4, left: 0, bottom: 0, right: 0)

        addSubview(contentView)
        let marginsGuide = layoutMarginsGuide
        contentView.mxAnchor(
            top: marginsGuide.topAnchor,
            leading: marginsGuide.leadingAnchor,
            bottom: marginsGuide.bottomAnchor,
            trailing: marginsGuide.trailingAnchor
        )
    }

    func setupContentViews() {
        contentView.addSubview(headerContentView)
        contentView.addSubview(middleContentView)
        contentView.addSubview(underLineView)
        contentView.addSubview(helperView)

        headerContentView.mxAnchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: middleContentView.topAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 0, bottom: SmokingCessation.spacing1, right: 0)
        )

        middleContentView.mxAnchor(
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor
        )

        underLineView.mxAnchor(
            top: middleContentView.bottomAnchor,
            leading: contentView.leadingAnchor,
            bottom: helperView.topAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: SmokingCessation.spacing1, left: 0, bottom: SmokingCessation.spacing1, right: 0),
            size: CGSize(width: 0, height: 1)
        )

        helperView.mxAnchor(
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor
        )
        helperView.heightAnchor.constraint(greaterThanOrEqualToConstant: SmokingCessation.spacing4).isActive = true
        setupMiddleView()
        setupUnderLineViewOther()
    }

    func setupMiddleView() {
        // Empty to allow inherit class to implement.
    }

    func setupUnderLineViewOther() {
        contentView.addSubview(underFocusedLineView)
        underFocusedLineView.mxAnchor(size: CGSize(width: 0, height: 1))
        underFocusedLineView.mxAnchorCenter(xAxis: underLineView.centerXAnchor, yAxis: underLineView.centerYAnchor)
        let defaultUnderHighlightedLineWidthConstraint = underFocusedLineView.widthAnchor.constraint(
            equalToConstant: 0
        )
        defaultUnderHighlightedLineWidthConstraint.isActive = true
        defaultUnderHighlightedLineWidthConstraint.priority = UILayoutPriority(750)

        underHighlightedLineWidthConstraint = underFocusedLineView.widthAnchor.constraint(equalTo: self.widthAnchor)
        underHighlightedLineWidthConstraint?.isActive = false

        contentView.addSubview(underErrorLineView)
        underErrorLineView.mxAnchor(
            leading: underLineView.leadingAnchor,
            trailing: underLineView.trailingAnchor,
            size: CGSize(width: 0, height: 1)
        )
        underErrorLineView.mxAnchorCenter(yAxis: underLineView.centerYAnchor)
    }

    func errorAnimation() {
        middleContentView.mxShake()
    }

    // MARK: update state
    private func updateUnderLineAndStartAnimation() {
        underFocusedLineView.isHidden = true
        underErrorLineView.isHidden = true
        underLineView.isHidden = false
        switch inputState {
        case .focus:
            startAnimation(isFocus: true)
        case .loseFocus:
            startAnimation(isFocus: false)
        case .error, .filledError:
            underErrorLineView.isHidden = false
        }
    }

    func updateUnderLineWithoutAnimation() {
        switch inputState {
        case .focus:
            underHighlightedLineWidthConstraint?.isActive = true
            underFocusedLineView.isHidden = false
            underErrorLineView.isHidden = true
            underLineView.backgroundColor = SmokingCessation.colorBackgroundSelectBase
        case .loseFocus:
            underFocusedLineView.isHidden = true
            underErrorLineView.isHidden = true
            underHighlightedLineWidthConstraint?.isActive = false
            underLineView.backgroundColor = SmokingCessation.colorBackgroundSecondaryWeak
        case .error, .filledError:
            underHighlightedLineWidthConstraint?.isActive = false
            underFocusedLineView.isHidden = true
            underErrorLineView.isHidden = false
        }
    }

    func inputStateChanged() {
        updateUnderLineAndStartAnimation()
        updateContentViews()
    }

    func updateContentViews() {
        updateMessageContentViews(temptMsg)
    }

    func startAnimation(isFocus: Bool) {
        guard underLineAnimator?.isRunning != true else {
            return
        }
        underLineAnimator?.stopAnimation(true)
        underHighlightedLineWidthConstraint?.isActive = isFocus ? true : false
        underFocusedLineView.isHidden = false
        underLineAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .linear) { [weak self] in
            self?.layoutIfNeeded()
        }
        underLineAnimator?.addCompletion({ [weak self] _ in
            self?.updateUnderLineWithoutAnimation()
        })
        underLineAnimator?.startAnimation()
    }

    // MARK: update View public function
    public func updateMessageContentViews(_ str: String? = nil, withState: TymeXInputState? = nil) {
        let state = withState ?? inputState
        let strValue = msgDefault.makeText() ?? ""
        helperView.updateContentView(state == .error ? .error(str ?? "") : .center(strValue))
        inputState = state
    }

    public func setHelperMessage(_ message: TymeXInputHelperMessageContent) {
        msgDefault.setContent(message)
        updateMessageContentViews()
    }

    public func showMessage(with msg: String, isError: Bool = true) {
        temptMsg = msg
        inputState = (isError && msg != "") ? .error : inputState
        if inputState == .error {
            errorAnimation()
            TymeXHapticFeedback.error.vibrate()
        }
        temptMsg = nil
    }
}

// MARK: Privates
extension TymeXBaseInputView {
    private func makeUnderErrorLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = SmokingCessation.colorBackgroundErrorBase
        view.isHidden = true
        return view
    }

    private func makeContentView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    private func makeMiddleContentView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    private func makeHeaderContentView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    private func makeUnderLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = SmokingCessation.colorBackgroundSecondaryWeak
        return view
    }

    private func makeUnderFocusedLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = SmokingCessation.colorBackgroundSelectBase
        view.isHidden = true
        return view
    }
}
