//
//  TymeXInputTextField.swift
//  TymeComponent
//
//  Created by Tuan Tran on 29/09/2022.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

@IBDesignable
public class TymeXInputTextField: TymeXBaseInputView {
    // MARK: - Properties
    public lazy var textView = makeTextField()
    public lazy var placeHolderLabel = makePlaceHolderLabel()
    public lazy var rightButton: UIButton = makeRightButton()
    var limitCharacter: Int?
    private lazy var directionMaterial = TymeXPlaceholderDirection.placeholderUp
    lazy var placeHolderWhileTypingPosition: CGFloat = 28.0
    var placeHolderTopConstraint: NSLayoutConstraint?

    // MARK: properties
    var placeHolderString: String = "" {
        didSet {
            updatePlaceHolderWithoutAnimate()
        }
    }

    // MARK: public properties
    public var isBecomeFirstResponder: Bool = false {
        didSet {
            textView.becomeFirstResponder()
        }
    }

    public var textInputed: String {
        return textView.text ?? ""
    }

    public var forceLowerCasedInput: Bool = false
    public var maximumNumberOfLines: Int = 2 {
        didSet {
            textView.textContainer.maximumNumberOfLines = maximumNumberOfLines
            placeHolderLabel.numberOfLines = maximumNumberOfLines
        }
    }

    public var keyboardType: UIKeyboardType = .default {
        didSet {
            textView.keyboardType = keyboardType
        }
    }

    public var returnKeyType: UIReturnKeyType = .default {
        didSet {
            textView.returnKeyType = returnKeyType
        }
    }

    public var filteringRegex: String?

    // MARK: CallBacks
    public var onTextViewDidChange: ((String) -> Void)?
    public var onEndEdited: ((String) -> Void)?
    public var onShouldReturn: (() -> Void)?

    public var isSpecialCharacterAllowed = true

    override var isTyping: Bool {
        return textView.isFirstResponder
    }

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
        middleContentView.addSubview(rightButton)
        middleContentView.addSubview(placeHolderLabel)

        rightButton.mxAnchor(
            trailing: middleContentView.trailingAnchor,
            size: getRightButtonSize()
        )

        rightButton.mxAnchorCenter(yAxis: middleContentView.centerYAnchor)

        let padding = UIEdgeInsets(
            top: 0,
            left: SmokingCessation.spacing6,
            bottom: 0,
            right: SmokingCessation.spacing6
        )
        textView.mxAnchor(
            top: middleContentView.topAnchor,
            leading: middleContentView.leadingAnchor,
            bottom: middleContentView.bottomAnchor,
            trailing: middleContentView.trailingAnchor,
            padding: padding
        )

        placeHolderLabel.mxAnchor(
            leading: textView.leadingAnchor,
            trailing: textView.trailingAnchor,
            size: CGSize(width: 0, height: 32.0)
        )
        placeHolderTopConstraint = placeHolderLabel.topAnchor.constraint(equalTo: textView.topAnchor)
        placeHolderTopConstraint?.isActive = true
    }

    public func getRightButtonSize() -> CGSize {
        return CGSize(width: 16.0, height: 16.0)
    }

    @objc func clearText() {
        let inputRange = NSRange(
            location: 0,
            length: textInputed.utf16.count
        )
        replaceInputValue(inputRange, "")
        onEndEdited?("")
    }

    func replaceInputValue(
        _ range: NSRange?,
        _ str: String
    ) {
        guard let start =
                textView.position(
                    from: textView.beginningOfDocument,
                    offset: range?.location ?? 0
                ),
              let end =
                textView.position(
                    from: start,
                    offset: range?.length ?? textInputed.length
                ),
              let textRange =
                textView.textRange(
                    from: start,
                    to: end
                )
        else { return }
        textView.replace(textRange, withText: str)
    }

    public func setLimitCharacter(_ number: Int) {
        limitCharacter = number
    }

    func formatInputValue(input: String?) -> String {
        guard let inputText = input, inputText != "" else { return "" }
        let currentLinesCount = textInputed.components(separatedBy: TymeXComponentConstants.lineSeperator).count
        let shouldBreakLine = (currentLinesCount < maximumNumberOfLines || maximumNumberOfLines == 0)
        let replacedText = inputText.replacingOccurrences(
            of: "\n",
            with: shouldBreakLine ? TymeXComponentConstants.lineSeperator : ""
        )
        var formattedValue = forceLowerCasedInput ? replacedText.lowercased() : replacedText
        if let pattern = filteringRegex {
            formattedValue = formattedValue.filteringCharacter(with: pattern)
        }
        return formattedValue
    }

    // MARK: update State
    override func updateContentViews() {
        updateTextField(content: textView.text)
        updateMessageContentViews(temptMsg)
    }

    public func updateTextField(content: String) {
        if textView.text.isEmpty && !isTyping {
            rightButton.isHidden = true
        } else {
            rightButton.isHidden = (textView.text.isEmpty || !isTyping)
        }
        textView.attributedText = NSAttributedString(
            string: content,
            attributes: SmokingCessation.textLabelEmphasizeL.color(inputState.colorInputField).alignment(textAlignment)
        )
        if !content.isEmpty && inputState == .loseFocus {
            animatePlaceholder()
        }
    }

    public func fillInputText(_ str: String? = nil, withState state: TymeXInputState = .loseFocus) {
        let formattedInput = formatInputValue(input: str)
        replaceInputValue(nil, formattedInput)
        inputState = state == .error ? .filledError : state

        if inputState == .loseFocus && (str?.isEmpty ?? false) {
            animatePlaceholder()
        }
    }

    public func makeTextField() -> UITextView {
        let textField = UITextView()
        // iOS 16 UITextView line spacing when empty https://developer.apple.com/forums/thread/711814
        _ = textField.layoutManager

        textField.autocorrectionType = .no
        textField.textContainerInset = UIEdgeInsets(top: SmokingCessation.spacing1, left: 0, bottom: SmokingCessation.spacing1, right: 0)
        textField.setContentCompressionResistancePriority(.required, for: .horizontal)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)
        textField.showsHorizontalScrollIndicator = false
        textField.showsVerticalScrollIndicator = false
        textField.autocapitalizationType = .none
        textField.isScrollEnabled = false
        textField.contentMode = .scaleToFill
        textField.textContainer.lineBreakMode = .byTruncatingHead
        textField.typingAttributes = SmokingCessation.textLabelEmphasizeL
            .color(inputState.colorInputField)
            .alignment(textAlignment)
        textField.delegate = self
        textField.backgroundColor = .clear
        return textField
    }

    @objc public func didTouchOnRightItem() {
        clearText()
    }

    // MARK: update config Field
    public func updateConfigTextField(
        placeHolder: String,
        numberOfLines: Int = 1,
        titleStr: String? = nil,
        defaultMessage: TymeXInputHelperMessage? = nil,
        filteringRegexFormat: String? = "[^A-Za-z0-9\\s_.,()-]"
    ) {
        placeHolderString = placeHolder
        inputTitleLabel = titleStr
        if let defaultMessage = defaultMessage {
            msgDefault = defaultMessage
        }
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

// MARK: - Make
extension TymeXInputTextField {
    func makePlaceHolderLabel() -> UILabel {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.lineBreakMode = .byTruncatingHead
        label.contentMode = .scaleToFill
        return label
    }

    @objc public func makeRightButton() -> UIButton {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.tintColor = SmokingCessation.colorIconDefault
        button.setImage(SmokingCessation().iconCancelFilled, for: .normal)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(didTouchOnRightItem), for: .touchUpInside)
        button.isHidden = true
        return button
    }

    func updateHelperMessage(text: String) {
        msgDefault.currentCharacterCount = text.count
        if msgDefault.shouldReloadHelperMessageOnTextChange {
            updateMessageContentViews()
        }
    }

    func updatePlaceHolderOnError(isFocused: Bool) {
        placeHolderLabel.attributedText = NSAttributedString(
            string: placeHolderString,
            attributes: SmokingCessation.textLabelDefaultL
                .color(isFocused ? SmokingCessation.colorTextError: SmokingCessation.colorTextSubtle)
                .alignment(textAlignment)
        )
    }
}
