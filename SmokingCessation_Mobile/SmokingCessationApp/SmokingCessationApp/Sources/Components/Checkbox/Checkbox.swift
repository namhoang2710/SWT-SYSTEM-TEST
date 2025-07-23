//
//  Checkbox.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit

open class Checkbox: UIView {
    public struct Configuration {
        private(set) public var title: String
        private(set) public var titleTypography: [NSAttributedString.Key: Any]
        private(set) public var checkIcon: UIImage?
        private(set) public var iconSize: CGSize
        private(set) public var checkIconSize: CGSize
        private(set) public var alignment: UIStackView.Alignment
        private(set) public var spacing: CGFloat
        private(set) public var isChecked: Bool

        public init(
            title: String,
            titleTypography: [NSAttributedString.Key: Any] = SmokingCessation.textLabelDefaultM.paragraphStyle(
                lineSpacing: 4,
                alignment: .left
            ),
            checkIcon: UIImage? = UIImage(
                named: "ic_check",
                in: Bundle(for: Checkbox.self),
                compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
            spacing: CGFloat = 8,
            isChecked: Bool = false
        ) {
            self.title = title
            self.titleTypography = titleTypography
            self.checkIcon = checkIcon
            self.iconSize = CGSize(width: 20, height: 20)
            self.checkIconSize = CGSize(width: 12, height: 10)
            self.alignment = .center
            self.spacing = spacing
            self.isChecked = isChecked
        }
    }

    private let stackView = UIStackView()
    private let checkBoxView = UIView()
    private let checkImageView = UIImageView()
    private let label = UILabel()

    private var configuration: Configuration
    public var isChecked: Bool = false {
        didSet {
            check(isChecked)
        }
    }

    public typealias BoxHandler = (Bool) -> Void
    public var tapBoxHandler: BoxHandler?
    var accessibilityID: String?

    public init(configuration: Configuration, accessibilityID: String? = nil) {
        self.accessibilityID = accessibilityID
        self.configuration = configuration
        super.init(frame: .zero)
        commonInit()
    }

    public init(accessibilityID: String? = nil) {
        self.accessibilityID = accessibilityID
        configuration = Configuration(title: "")
        super.init(frame: .zero)
        commonInit()
    }

    required public init?(coder: NSCoder) {
        configuration = Configuration(title: "")
        super.init(coder: coder)
        commonInit()
    }

    open func commonInit() {
        layoutViews()
        updateContents()
        handleActions()
        isChecked = configuration.isChecked
        check(configuration.isChecked)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        set(
            .init(
                title: configuration.title,
                checkIcon: configuration.checkIcon,
                isChecked: isChecked
            )
        )
    }

    open func updateContents() {
        label.attributedText =  NSAttributedString(
            string: configuration.title,
            attributes: configuration.titleTypography
        )
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
    }

    open func layoutViews() {
        checkBoxView.addSubview(checkImageView)
        stackView.addArrangedSubview(checkBoxView)
        stackView.addArrangedSubview(label)
        stackView.axis = .horizontal
        stackView.spacing = configuration.title.isEmpty ? 0 : configuration.spacing
        stackView.alignment = configuration.alignment

        addSubview(stackView)

        checkBoxView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkBoxView.widthAnchor.constraint(equalToConstant: configuration.iconSize.width),
            checkBoxView.heightAnchor.constraint(equalToConstant: configuration.iconSize.height)
        ])
        checkBoxView.mxCircledCorners()

        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkImageView.centerXAnchor.constraint(equalTo: checkBoxView.centerXAnchor),
            checkImageView.centerYAnchor.constraint(equalTo: checkBoxView.centerYAnchor),
            checkImageView.widthAnchor.constraint(
                equalToConstant: configuration.checkIconSize.width),
            checkImageView.heightAnchor.constraint(
                equalToConstant: configuration.checkIconSize.height)
        ])
        checkImageView.contentMode = .scaleAspectFit

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor)
        ])

        stackView.layoutIfNeeded()
    }

    open func handleActions() {
        let checkboxTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapOnCheckBox)
        )
        checkBoxView.addGestureRecognizer(checkboxTapGesture)
    }

    @objc open func handleTapOnCheckBox() {
        isChecked.toggle()
        tapBoxHandler?(isChecked)
    }

    open func set(_ configuration: Configuration) {
        self.configuration = configuration
        layoutViews()
        updateContents()
        isChecked = configuration.isChecked
    }

    private func check(_ isChecked: Bool) {
//        let isChecked = true
        checkImageView.isHidden = !isChecked
        checkBoxView.backgroundColor =
        isChecked ? SmokingCessation.primaryColor : .white
        checkImageView.image = isChecked ? configuration.checkIcon : nil
        checkImageView.tintColor = isChecked ? .white : SmokingCessation.secondaryColor
        checkBoxView.mxBorderWidth = isChecked ? 0 : 1
        checkBoxView.mxBorderColor = isChecked ? .white : SmokingCessation.secondaryColor
    }
}
