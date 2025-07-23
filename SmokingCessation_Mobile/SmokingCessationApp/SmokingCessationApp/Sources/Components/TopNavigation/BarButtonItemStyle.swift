//
//  BarButtonItemStyle.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import UIKit

typealias BarButtonTuple = (button: UIBarButtonItem?, width: CGFloat)

enum BarButtonItemType: Equatable {
    case left
    case right
}

public enum BarButtonItemStyle: Equatable {
    public static let lightBackButton: BarButtonItemStyle = .icon(SmokingCessation().iconArrowLeft)
    public static let darkBackButton: BarButtonItemStyle = .icon(SmokingCessation().iconArrowLeftInverse)

    case icon(_ image: UIImage?)
    case button( _ title: String)
    case empty
    case customView(_ view: UIView)

    enum Constants {
        static let iconSize: CGSize = CGSize(width: 24.0, height: 24.0)
        static let topPaddingBarOutlinedButton: CGFloat = 4.0
    }
}

extension BarButtonItemStyle {
    static let borderBarButtonItem: CGFloat = 1.0
    func makeBarButtonTuple(
        action: TymeXCompletion?,
        mode: NavigationMode,
        heightNaviBar: CGFloat,
        type: BarButtonItemType
    ) -> BarButtonTuple {
        switch self {
        case .icon(let image):
            guard let image = image else {
                return makeBarButtonTupleEmpty()
            }
            return makeBarButtonTuple(
                target: self,
                action: action,
                image: image,
                heightNaviBar: heightNaviBar,
                type: type
            )
        case .customView(let customView):
            return makeBarButtonTuple(
                target: self,
                action: action,
                customView: customView,
                heightNaviBar: heightNaviBar,
                type: type
            )
        case .button(let title):
            guard !title.isEmpty else {
                return makeBarButtonTupleEmpty()
            }
            return makeBarButtonTuple(
                target: self,
                action: action,
                title: title,
                heightNaviBar: heightNaviBar,
                mode: mode,
                type: type
            )
        case .empty:
            return makeBarButtonTupleEmpty()
        }
    }
}

// MARK: - Supports
extension BarButtonItemStyle {
    private func makeBarButtonTupleEmpty() -> BarButtonTuple {
        return (nil, 0.0)
    }

    private func makeBarButtonTuple(
        target: Any?,
        action: TymeXCompletion?,
        image: UIImage?,
        heightNaviBar: CGFloat,
        type: BarButtonItemType
    ) -> BarButtonTuple {
        let iconSize = Constants.iconSize
        let containerView = UIView(
            frame: CGRect(origin: .zero, size: CGSize(
                width: iconSize.width,
                height: heightNaviBar
            ))
        )
        let widthButton = iconSize.width + 4
        let yPositionButton = (containerView.frame.height - iconSize.height)/2
        let buttonFrame = CGRect(
            x: 0, y: yPositionButton,
            width: widthButton, height: iconSize.height
        )
        let button = UIButton(frame: buttonFrame)
        button.setImage(image, for: .normal)
        switch type {
        case .left:
            button.imageEdgeInsets.left = 0.0
        case .right:
            button.imageEdgeInsets.left = 4
        }
        containerView.addSubview(button)

        // setup accessibilityIdentifier for UIButton
        if type == .left {
            button.accessibilityIdentifier = "leftNavigationBarIconButton"
        } else {
            button.accessibilityIdentifier = "rightNavigationBarIconButton"
        }

        let barItem = BarButtonItem(
            customView: containerView,
            actionHandler: action
        )
        barItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        barItem.customView?.heightAnchor.constraint(equalToConstant: heightNaviBar).isActive = true
        barItem.customView?.widthAnchor.constraint(equalToConstant: widthButton).isActive = true
        return (barItem, (widthButton + 16))
    }

    private func makeBarButtonTuple(
        target: Any?,
        action: TymeXCompletion?,
        customView: UIView,
        heightNaviBar: CGFloat,
        type: BarButtonItemType
    ) -> BarButtonTuple {
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.removeWidthHeightContraints()

        let iconSize = Constants.iconSize
        let containerView = UIView()
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: iconSize.width),
            containerView.heightAnchor.constraint(equalToConstant: heightNaviBar)
        ])
        containerView.addSubview(customView)
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: containerView.topAnchor),
            customView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            customView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            customView.rightAnchor.constraint(equalTo: containerView.rightAnchor)
        ])

        // setup accessibilityIdentifier for CustomView
        if type == .left {
            customView.accessibilityIdentifier = "leftNavigationBarCustomView"
        } else {
            customView.accessibilityIdentifier = "rightNavigationBarCustomView"
        }

        let barItem = BarButtonItem(
            customView: containerView,
            actionHandler: action
        )
        barItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        barItem.customView?.heightAnchor.constraint(equalToConstant: heightNaviBar).isActive = true
        barItem.customView?.widthAnchor.constraint(equalToConstant: iconSize.width).isActive = true
        return (barItem, (iconSize.width + 16))
    }

    // swiftlint:disable:next function_parameter_count
    private func makeBarButtonTuple(
        target: Any?,
        action: TymeXCompletion?,
        title: String,
        heightNaviBar: CGFloat,
        mode: NavigationMode,
        type: BarButtonItemType
    ) -> BarButtonTuple {
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: SmokingCessation.textLabelEmphasizeS
        )
        let widthAttribute = max(30, ceil(attributedTitle.size().width))
        let widthButton = widthAttribute + 2*12
        let customView = UIView(
            frame: CGRect(origin: .zero, size: CGSize(
                width: widthButton,
                height: heightNaviBar
            ))
        )
        let button = makeTertiaryOutlinedButton(title: title, mode: mode)
        customView.addSubview(button)

        // setup accessibilityIdentifier for buttonTitle
        if type == .left {
            button.accessibilityIdentifier = "leftNavigationBarButtonTitle"
        } else {
            button.accessibilityIdentifier = "rightNavigationBarButtonTitle"
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(
            equalTo: customView.topAnchor,
            constant: Constants.topPaddingBarOutlinedButton
        ).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: widthButton).isActive = true

        let barItem = BarButtonItem(
            customView: customView,
            actionHandler: action
        )
        barItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        barItem.customView?.heightAnchor.constraint(equalToConstant: heightNaviBar).isActive = true
        barItem.customView?.widthAnchor.constraint(equalToConstant: widthButton).isActive = true
        return (barItem, (widthButton + 16))
    }

    private func makeTertiaryOutlinedButton(
        title: String, mode: NavigationMode) -> TertiaryOutlinedButton {
        let button = TertiaryOutlinedButton()
        button.setup(
            configuration: ButtonConfiguration(contentMode: .text(title))
        )
            switch mode {
            case .dark:
                button.textLabel.textColor = SmokingCessation.colorTextInverse
                button.normalColor = SmokingCessation.colorBackgroundSecondaryBase
                button.highlightedColor = SmokingCessation.colorBackgroundSecondaryBase
                button.backgroundView.layer.borderWidth = BarButtonItemStyle.borderBarButtonItem
                button.backgroundView.layer.borderColor = SmokingCessation.colorDividerWhite.cgColor
                button.backgroundView.backgroundColor = SmokingCessation.colorBackgroundSecondaryBase
            case .light:
                button.textLabel.textColor = SmokingCessation.colorTextDefault
                button.normalColor = SmokingCessation.colorStrokeSecondaryLight
                button.highlightedColor = SmokingCessation.colorStrokeSecondaryLight
                button.backgroundView.layer.borderWidth = 1
                button.backgroundView.layer.borderColor = SmokingCessation.colorStrokeSecondaryWeak.cgColor
            }
        return button
    }
}
