//
//  TymeXInputTextField.swift
//  TymeComponent
//
//  Created by Tuan Tran on 29/09/2022.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

@IBDesignable
public class TymeXInputDropdownField: TymeXBaseInputView {
    // MARK: - Properties
    public lazy var textView = makeTextField()
    private(set) lazy var placeHolderLabel = makePlaceHolderLabel()
    private lazy var clearButton: UIButton = makeClearButton()
    private lazy var arrowButton: UIButton = makeArrowButton()
    private var dropdownListView: UIView?
    private let clearButtonSize: CGSize = CGSize(width: 16.0, height: 16.0)
    private var limitCharacter: Int?
    private lazy var directionMaterial = TymeXPlaceholderDirection.placeholderUp
    private lazy var placeHolderWhileTypingPosition: CGFloat = 28.0
    private var placeHolderTopConstraint: NSLayoutConstraint?

    // MARK: properties
    var placeHolderString: String = "" {
        didSet {
            updatePlaceHolderWithoutAnimate()
        }
    }
    private var isDropdownExterned: Bool = false {
        didSet {
            if isDropdownExterned {
                arrowButton.setImage(SmokingCessation().iconChevronDown, for: .normal)
            } else {
                arrowButton.setImage(SmokingCessation().iconChevronUp, for: .normal)
            }
        }
    }
    override var isTyping: Bool {
        return textView.isFirstResponder
    }

    // MARK: public properties
    public var forceLowerCasedInput: Bool = false
    public var maximumNumberOfLines: Int = 2 {
        didSet {
            textView.textContainer.maximumNumberOfLines = maximumNumberOfLines
            placeHolderLabel.numberOfLines = maximumNumberOfLines
        }
    }
    public var textInputed: String {
        return textView.text ?? ""
    }
    public var isBecomeFirstResponder: Bool = false {
        didSet {
            textView.becomeFirstResponder()
        }
    }
    public var returnKeyType: UIReturnKeyType = .default {
        didSet {
            textView.returnKeyType = returnKeyType
        }
    }
    public var keyboardType: UIKeyboardType = .default {
        didSet {
            textView.keyboardType = keyboardType
        }
    }
    public var filteringRegex: String?
    // MARK: CallBacks
    public var onEndEdited: ((String) -> Void)?
    public var onShouldReturn: (() -> Void)?
    public var isSpecialCharacterAllowed = true
    // MARK: setup Views
    override func setupView() {
        super.setupView()
        textView.textAlignment = textAlignment
        textView.keyboardType = keyboardType
        textView.textContainer.maximumNumberOfLines = maximumNumberOfLines
        textView.returnKeyType = returnKeyType

        placeHolderLabel.textAlignment = textAlignment
        placeHolderLabel.numberOfLines = maximumNumberOfLines
    }

    override func setupMiddleView() {
        middleContentView.addSubview(textView)
        middleContentView.addSubview(clearButton)
        middleContentView.addSubview(arrowButton)
        middleContentView.addSubview(placeHolderLabel)

        clearButton.mxAnchor(
            trailing: middleContentView.trailingAnchor,
            size: clearButtonSize
        )
        clearButton.mxAnchorCenter(yAxis: middleContentView.centerYAnchor)
        arrowButton.mxAnchor(
            trailing: middleContentView.trailingAnchor,
            size: clearButtonSize
        )
        arrowButton.mxAnchorCenter(yAxis: middleContentView.centerYAnchor)
        textView.mxAnchor(
            top: middleContentView.topAnchor,
            leading: middleContentView.leadingAnchor,
            bottom: middleContentView.bottomAnchor,
            trailing: middleContentView.trailingAnchor,
            padding: UIEdgeInsets(
                top: 0,
                left: SmokingCessation.spacing6,
                bottom: 0,
                right: SmokingCessation.spacing6
            )
        )

        placeHolderLabel.mxAnchor(
            leading: textView.leadingAnchor,
            trailing: textView.trailingAnchor,
            size: CGSize(width: .zero, height: 32.0)
        )
        placeHolderTopConstraint = placeHolderLabel.topAnchor.constraint(equalTo: textView.topAnchor)
        placeHolderTopConstraint?.isActive = true
    }

    @objc private func clearText() {
        let inputRange = NSRange(location: 0, length: textInputed.utf16.count)
        replaceInputValue(inputRange, "")
        onEndEdited?("")
    }

    func replaceInputValue(_ range: NSRange?, _ str: String) {
        guard let replaceStart =
                textView.position(
                    from: textView.beginningOfDocument,
                    offset: range?.location ?? 0
                ),
              let replaceEnd =
                textView.position(
                    from: replaceStart,
                    offset: range?.length ?? textInputed.length
                ),
              let textRange =
                textView.textRange(
                    from: replaceStart,
                    to: replaceEnd
                )
        else { return }
        textView.replace(textRange, withText: str)
    }

    public func setLimitCharacter(_ number: Int) {
        limitCharacter = number
    }

    func formatInputValue(input: String?) -> String {
        guard let str = input, str != "" else { return "" }
        let currentLinesCount = textInputed.components(separatedBy: TymeXComponentConstants.lineSeperator).count
        let shouldBreakLine = (currentLinesCount < maximumNumberOfLines || maximumNumberOfLines == 0)
        let tText = str.replacingOccurrences(
            of: "\n",
            with: shouldBreakLine ? TymeXComponentConstants.lineSeperator : ""
        )
        var formattedValue = forceLowerCasedInput ? tText.lowercased() : tText
        if let pattern = filteringRegex {
            formattedValue = formattedValue.filteringCharacter(with: pattern)
        }
        return formattedValue
    }

    // MARK: update State
    override func updateContentViews() {
        updateTextField()
        updateMessageContentViews(temptMsg)
    }

    private func updatePlaceholderOnError(isFocused: Bool) {
        placeHolderLabel.attributedText = NSAttributedString(
            string: placeHolderString,
            attributes: SmokingCessation.textLabelDefaultXs
                .color(isFocused ? SmokingCessation.colorTextError: SmokingCessation.colorTextSubtle)
                .alignment(.center)
        )
    }

    public func updatePlaceHolderWithoutAnimate() {
        placeHolderLabel.attributedText = getPlaceHolderAttributedString(
            placeHolderString,
            isEmptyText: textView.text.isEmpty
        )
    }

    func updateTextField() {
        if !textView.text.isEmpty || isTyping {
            textView.attributedText = NSAttributedString(
                string: textView.text,
                attributes: SmokingCessation.textLabelEmphasizeL.color(inputState.colorInputField).alignment(.center)
            )
            animatePlaceholder()
        }
    }

    public func fillInputText(_ str: String? = nil, withState state: TymeXInputState = .loseFocus) {
        let formattedInput = formatInputValue(input: str)
        replaceInputValue(nil, formattedInput)
        inputState = state == .error ? .filledError : state
    }

    // MARK: update config Field
    public func updateConfigTextField(
        placeHolder: String,
        numberOfLines: Int = 1,
        titleStr: String? = nil,
        defaultMessage: TymeXInputHelperMessage? = nil,
        filteringRegexFormat: String? = "[^A-Za-z0-9\\s_.,()-]",
        dropdownListView: UIView? = nil
    ) {
        placeHolderString = placeHolder
        inputTitleLabel = titleStr
        fillInputText(titleStr, withState: .loseFocus)
        if let defaultMessage = defaultMessage {
            msgDefault = defaultMessage
        }
        arrowButton.isHidden = false
        filteringRegex = filteringRegexFormat
        updateContentViews()
        self.setNeedsLayout()
    }

    override func inputStateChanged() {
        super.inputStateChanged()
        textView.tintColor = inputState.inputTextFieldTintColor
        animatePlaceholder()
    }
}

// MARK: - UITextViewDelegate
extension TymeXInputDropdownField: UITextViewDelegate {
    public func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        if text == "\n" && returnKeyType != .default {
            onShouldReturn?()
            return false
        }
        let formattedInput = formatInputValue(input: text)
        let modifiedTextView = (textView.text as NSString).replacingCharacters(in: range, with: formattedInput)
        if let maxLength = self.limitCharacter, modifiedTextView.count > maxLength {
            TymeXHapticFeedback.light.vibrate()
            mxShake()
            return false
        }
        replaceInputValue(range, formattedInput)
        updateHelperMessage(text: modifiedTextView)
        return false
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        if inputState != .error || textView.text.isEmpty {
            inputState = .focus
        } else if inputState == .error {
            updatePlaceholderOnError(isFocused: true)
        }
        isDropdownExterned = false
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        onEndEdited?(textView.text)
        if inputState != .error || textView.text.isEmpty {
            inputState = .loseFocus
        } else if inputState == .error {
            updatePlaceholderOnError(isFocused: false)
        } else {
            updateTextField()
        }
        isDropdownExterned = true
    }

    public func textViewDidChange(_ textView: UITextView) {
        // Because textViewDidBeginEditing, we ignore input state is error
        // We shouldn't remove this statement, because the inputStateChanged() executed too many times
        // Reproduce: executing fillInputText() at viewWillAppear()
        if inputState == .error {
            inputState = .focus
        } else {
            updateContentViews()
        }
    }
}

// MARK: - Privates
extension TymeXInputDropdownField {
    private func makeTextField() -> UITextView {
        let field = UITextView()
        // iOS 16 UITextView line spacing when empty https://developer.apple.com/forums/thread/711814
        _ = field.layoutManager
        field.autocorrectionType = .no
        field.textContainerInset = UIEdgeInsets(top: SmokingCessation.spacing1, left: 0, bottom: SmokingCessation.spacing1, right: 0)
        field.setContentCompressionResistancePriority(.required, for: .horizontal)
        field.setContentCompressionResistancePriority(.required, for: .vertical)
        field.autocapitalizationType = .none
        field.showsHorizontalScrollIndicator = false
        field.showsVerticalScrollIndicator = false
        field.isScrollEnabled = false
        field.contentMode = .scaleToFill
        field.textContainer.lineBreakMode = .byTruncatingHead
        field.typingAttributes = SmokingCessation.textLabelEmphasizeL.color(inputState.colorInputField).alignment(.center)
        field.delegate = self
        field.backgroundColor = .clear
        return field
    }

    private func makePlaceHolderLabel() -> UILabel {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.lineBreakMode = .byTruncatingHead
        label.contentMode = .scaleToFill
        return label
    }

    private func makeClearButton() -> UIButton {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.tintColor = SmokingCessation.colorIconDefault
        button.setImage(SmokingCessation().iconCancelFilled, for: .normal)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        button.isHidden = true
        return button
    }

    private func makeArrowButton() -> UIButton {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.tintColor = .clear
        button.setImage(SmokingCessation().iconChevronDown, for: .normal)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        button.isHidden = true
        return button
    }

    private func makeDropdownContainerView() -> UIView {
        let view = UIView()
        return view
    }

    private func updateHelperMessage(text: String) {
        msgDefault.currentCharacterCount = text.count
        if msgDefault.shouldReloadHelperMessageOnTextChange {
            updateMessageContentViews()
        }
    }

    private func animatePlaceholder() {
        let animationConfig = AnimationConfiguration(duration: .duration4, motionEasing: .motionEasingDefault)
        let placeHolderYValue: Double
        var scale = 1.0
        if textView.text.isEmpty && !isTyping {
            placeHolderYValue = 0
            scale = 12/20
        } else {
            placeHolderYValue = -placeHolderWhileTypingPosition
            scale = 20/12
        }
        if let placeHolderTopConstraint = placeHolderTopConstraint {
            placeHolderLabel.mxAnimateConstraints(
                constraint: placeHolderTopConstraint, constant: placeHolderYValue, configuration: animationConfig
            )
        }
        let toAttrs = getPlaceHolderAttributedString(placeHolderString, isEmptyText: textView.text.isEmpty)
        let fromAttrs = placeHolderLabel.attributedText ?? toAttrs
        if textView.text.isEmpty {
            placeHolderLabel.mxAnimateScaleAndUpdateAttributes(
                fromAttrs: fromAttrs,
                toAttrs: toAttrs,
                scaleRatio: scale,
                duration: AnimationDuration.duration4.value,
                animateAnchorPoint: LabelAnimateAnchorPoint.centerXCenterY
            )
        } else {
            updatePlaceHolderWithoutAnimate()
        }
    }
}
