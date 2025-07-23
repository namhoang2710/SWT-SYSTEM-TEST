//
//  SegmentControl.swift
//  TymeXUIComponent
//
//  Created by Nalou Nguyen on 13/10/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

/**
 Segment Control View

 # Example #
 ```
 // 1. Create via interface builder, then call:
 segmentView.setItems(["Item 1", "Item 2", "Item 3"]) { (index) in
 print("selected item", index)
 }
 // 2. Create programmatically:
 let segmentView = SegmentControl(frame: CGRect(x: 0, y: 0, width: 300, height: 32))
 view.addSubview(segmentView)
 segmentView.setItems(["Item 1", "Item 2", "Item 3"]) { (index) in
 print("selected item", index)
 }
 ```
 */
@IBDesignable
public class TymeXSegmentControl: TymeXBaseView {
    // MARK: - Properties
    public private(set) var selectedIndex: Int = 0

    // MARK: - Public variables
    public var textAttributes = SmokingCessation.textLabelEmphasizeS
    public var selectedTextAttributes = SmokingCessation.textLabelEmphasizeS

    // MARK: - Inspectable variables
    @IBInspectable public var normalTextColor: UIColor = SmokingCessation.colorTextDefault
    @IBInspectable public var selectedTextColor: UIColor = SmokingCessation.colorTextInverse

    @IBInspectable public var selectColor: UIColor = SmokingCessation.colorBackgroundSelectBase {
        didSet { thumbView.backgroundColor = selectColor }
    }

    // MARK: - Private Properties
    public var didSelectClosure: ((Int) -> Void)?

    // MARK: - Private UI variables
    private var buttons = [UIButton]()
    private var thumbView: UIView!
    lazy private var backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.borderColor = SmokingCessation.colorStrokeInfoHeavy.cgColor
        layer.backgroundColor = SmokingCessation.colorBackgroundInfoBase.cgColor
        return layer
    }()

    // MARK: - Init methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Override methods
    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = bounds
        layoutItems()
    }

    public override func loadViewFromNib() -> UIView? { return nil }
}

// MARK: - Public methods
extension TymeXSegmentControl {
    func getButtons() -> [UIButton] {
        return buttons
    }

    // set items with titles
    public func setItems(_ items: [String], selectClosure: ((Int) -> Void)?) {
        didSelectClosure = selectClosure
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        for item in items {
            let button = makeButton(title: item)
            // add to view
            addSubview(button)
            buttons.append(button)
        }
        selectItem(at: 0, animated: false)
        self.setNeedsLayout()
    }

    // select item and emit event
    public func selectItem(at index: Int, animated: Bool = true) {
        guard index < buttons.count else {
            return
        }
        selectedIndex = index
        let selectedButton = self.buttons[index]
        let selectedButtonCenter = selectedButton.center

        let pillAnimation = AnimationConfiguration(
            duration: .duration2,
            motionEasing: .motionEasingDefault
        )

        for (cur, button) in buttons.enumerated() {
            if animated {
                UIView.transition(
                    with: button,
                    duration: AnimationDuration.duration3.value,
                    options: .transitionCrossDissolve,
                    animations: {
                        button.isSelected = cur == index
                    }
                )
            } else {
                button.isSelected = cur == index
            }
        }

        if animated {
            UIView.mxAnimateBy(pillAnimation) { [weak self] in
                self?.thumbView.center = selectedButtonCenter
            }
        } else {
            thumbView.center = selectedButtonCenter
        }
    }

    // set items with titles and icons
    public func setItems(_ items: [(title: String, selectIcon: UIImage?)], selectClosure: ((Int) -> Void)?) {
        didSelectClosure = selectClosure

        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        for item in items {
            let button = makeButton(title: item.title, selectIcon: item.selectIcon)
            // add to view
            addSubview(button)

            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            buttons.append(button)
        }
        selectItem(at: 0, animated: false)
        self.setNeedsLayout()
    }
}

// MARK: - Private methods
extension TymeXSegmentControl {
    private func setup() {
        mxBorderColor = SmokingCessation.colorStrokeInfoHeavy
        backgroundLayer.frame = self.bounds.insetBy(dx: -1.0, dy: -1.0)
        self.layer.addSublayer(backgroundLayer)

        // setup selected view
        thumbView = UIView(frame: self.bounds)
        thumbView.backgroundColor = selectColor
        addSubview(thumbView)
    }

    private func layoutItems() {
        var xPosition: CGFloat = 0
        let height: CGFloat = self.bounds.height
        let width: CGFloat = self.bounds.width / CGFloat(buttons.count)

        // update corner radius
        backgroundLayer.cornerRadius = getCornerRadiusBase()
        thumbView.layer.cornerRadius = getCornerRadiusBase()

        // set thumb view frame
        let inset = CGFloat(backgroundLayer.borderWidth)
        thumbView.frame = CGRect(
          x: inset,
          y: inset,
          width: width - 2*inset,
          height: height - 2*inset
        )

        for button in buttons {
            // align item
            button.frame = CGRect(x: xPosition, y: 0, width: width, height: height)
            // re-calculate x position
            xPosition = button.frame.maxX

            // check to update thumb view position
            if button.isSelected {
                thumbView.center = button.center
            }
        }
    }

    @objc private func handleTap(_ sender: UIButton) {
        guard !sender.isSelected else {
            return
        }
        if let index = buttons.firstIndex(of: sender) {
            selectItem(at: index)
            didSelectClosure?(index)
        }
    }

    // create icon segment button
    private func makeButton(title: String, selectIcon: UIImage? = nil) -> UIButton {
        let button = UIButton(type: .custom)
        button.titleLabel?.accessibilityIdentifier = "titleLabelSegmentButton\(type(of: self))"
        if let selectIcon = selectIcon {
            button.setImage(selectIcon, for: .selected)
            button.imageView?.tintColor = SmokingCessation.colorTextDefault
        }
        button.setAttributedTitle(
            NSAttributedString(
                string: title,
                attributes: textAttributes.color(normalTextColor)
            ),
            for: .normal
        )
        button.setAttributedTitle(
            NSAttributedString(
                string: title,
                attributes: selectedTextAttributes.color(selectedTextColor)
            ),
            for: .selected
        )
        button.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
        return button
    }
}
