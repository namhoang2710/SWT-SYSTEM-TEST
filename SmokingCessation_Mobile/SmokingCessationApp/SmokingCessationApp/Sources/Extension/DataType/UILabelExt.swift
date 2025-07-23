//
//  UILabelExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

extension UILabel {
    func setStrikethrough(text: String, startLocation: Int, length: Int, attribute: [NSAttributedString.Key: Any]) {
        let maxLengthAllowed = text.count - startLocation
        let currLength = (length >= maxLengthAllowed) ? maxLengthAllowed : length
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: text)
        attributeString.setAttributes(attribute, range: NSRange(location: 0, length: text.length))
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: startLocation, length: currLength)
        )
        self.attributedText = attributeString
    }

    func textWidth() -> CGFloat {
        let tmpLabel = UILabel(frame: self.bounds)
        tmpLabel.attributedText = self.attributedText
        return tmpLabel.intrinsicContentSize.width
    }
}

struct LabelAnimateAnchorPoint {
    static let leadingCenterY         = CGPoint.init(x: 0, y: 0.5)
    static let trailingCenterY        = CGPoint.init(x: 1, y: 0.5)
    static let centerXCenterY         = CGPoint.init(x: 0.5, y: 0.5)
    static let leadingTop             = CGPoint.init(x: 0, y: 0)
}

extension UILabel {
    func mxAnimateUpdateAttributes(
        attributeString: NSAttributedString,
        animatingAttributeString: NSAttributedString,
        scaleRatio: CGFloat,
        duration: TimeInterval,
        animateAnchorPoint: CGPoint) {
        let startTransform = transform
        let oldFrame = frame
        var newFrame = oldFrame
        let archorPoint = layer.anchorPoint

        layer.anchorPoint = animateAnchorPoint

        newFrame.size.width *= scaleRatio
        newFrame.size.height *= scaleRatio
        newFrame.origin.x = oldFrame.origin.x - (newFrame.size.width - oldFrame.size.width) * animateAnchorPoint.x
        newFrame.origin.y = oldFrame.origin.y - (newFrame.size.height - oldFrame.size.height) * animateAnchorPoint.y
        frame = newFrame
        self.attributedText = animatingAttributeString

        transform = CGAffineTransform.init(scaleX: 1 / scaleRatio, y: 1 / scaleRatio)
        layoutIfNeeded()

        UIView.animate(withDuration: duration, animations: {
            self.transform = startTransform
            newFrame = self.frame
        }, completion: { (_) in
            self.attributedText = attributeString
            self.layer.anchorPoint = archorPoint
        })
    }

    func mxAnimateScaleAndUpdateAttributes(
        fromAttrs: NSAttributedString,
        toAttrs: NSAttributedString,
        scaleRatio: CGFloat,
        duration: TimeInterval,
        animateAnchorPoint: CGPoint = CGPoint.zero) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(AnimationDuration.duration4.value)
        CATransaction.setAnimationTimingFunction(MXMotionEasing.motionEasingDefault.caType)
        let oldFrame = frame
        var newFrame = oldFrame
        let archorPoint = layer.anchorPoint
        newFrame.size.width *= scaleRatio
        newFrame.size.height *= scaleRatio
        newFrame.origin.x = oldFrame.origin.x - (newFrame.size.width - oldFrame.size.width) * animateAnchorPoint.x
        newFrame.origin.y = oldFrame.origin.y - (newFrame.size.height - oldFrame.size.height) * animateAnchorPoint.y
        frame = newFrame
        UIView.animate(withDuration: duration, animations: {
            self.attributedText = fromAttrs
            self.transform = CGAffineTransform(scaleX: 1 / scaleRatio, y: 1 / scaleRatio)
            self.layoutIfNeeded()
        }, completion: { (_) in
            self.layer.anchorPoint = archorPoint
            self.attributedText = toAttrs
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        CATransaction.commit()
    }

    func mxAnimateToHide() {
        var frame = self.frame
        frame.size.height = 0

        CATransaction.begin()
        CATransaction.setAnimationDuration(AnimationDuration.duration5.value)
        CATransaction.setAnimationTimingFunction(MXMotionEasing.motionEasingDefault.caType)
        UIView.animate(withDuration: AnimationDuration.duration5.value, delay: 0, animations: {
            self.alpha = 0
            self.frame = frame
            self.isHidden = true
            self.superview?.layoutIfNeeded()
        }, completion: { _ in
            self.isHidden = true
        })

        CATransaction.commit()
    }
}
