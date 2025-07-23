//
//  AnimationMaker.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import UIKit

final class AnimationMaker {
    func makeButtonHighlightBackground(
        fromColor: UIColor,
        toColor: UIColor,
        bounds: CGRect,
        cornerRadius: CGFloat
    ) -> CALayer {
        let name = "highlightedLayer"
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = fromColor.cgColor
        animation.toValue = toColor.cgColor
        animation.duration = 0.1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        let animationLayer = CALayer()
        animationLayer.name = name
        animationLayer.frame = bounds
        animationLayer.cornerRadius = cornerRadius
        animationLayer.add(animation, forKey: "backgroundColor")
        return animationLayer
    }

    func makeOTPFieldHighlightBackground(
        fromColor: UIColor,
        toColor: UIColor,
        animationDuration: Double,
        repeatCount: Float
    ) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = fromColor.cgColor
        animation.toValue = toColor.cgColor
        animation.duration = animationDuration
        animation.beginTime = CACurrentMediaTime()
        animation.timingFunction = MXMotionEasing.motionEasingDefault.caType
        animation.autoreverses = true
        animation.repeatCount = repeatCount
        return animation
    }

    func makeButtonExpandAnimation(
        bounds: CGRect,
        cornerRadius: CGFloat,
        backgroundColor: UIColor
    ) -> CALayer {
        let anim = CABasicAnimation(keyPath: "transform.scale.x")
        anim.fromValue = 0
        anim.toValue = 1
        anim.duration = 0.3

        let animColor = CAKeyframeAnimation()
        animColor.keyPath = "opacity"
        animColor.values = [0, 1]
        animColor.keyTimes = [0, 1]
        animColor.duration = 0.3

        let groupAnim = CAAnimationGroup()
        groupAnim.animations = [anim, animColor]
        groupAnim.duration = 0.3

        let animLayer = CALayer()
        animLayer.frame = bounds
        animLayer.cornerRadius = cornerRadius
        animLayer.add(groupAnim, forKey: nil)
        animLayer.backgroundColor = backgroundColor.cgColor
        animLayer.opacity = 1
        return animLayer
    }

    func makeButtonCollapseAnimation(
        bounds: CGRect,
        cornerRadius: CGFloat,
        backgroundColor: UIColor
    ) -> CALayer {
        let animColor = CABasicAnimation(keyPath: "opacity")
        animColor.toValue = 0
        animColor.duration = 0.3

        let animLayer = CALayer()
        animLayer.frame = bounds
        animLayer.cornerRadius = cornerRadius
        animLayer.add(animColor, forKey: nil)
        animLayer.backgroundColor = backgroundColor.cgColor
        animLayer.opacity = 0
        return animLayer
    }

    func makeButtonRippleBackground(
        at position: CGPoint,
        bounds: CGRect,
        backgroundColor: UIColor
    ) -> CAShapeLayer {
        let rippleLayer = CAShapeLayer()
        let maxWidth = bounds.width * 2
        rippleLayer.frame = CGRect(origin: .zero, size: CGSize(width: maxWidth, height: maxWidth))
        rippleLayer.cornerRadius = maxWidth / 2
        rippleLayer.position = position
        rippleLayer.backgroundColor = backgroundColor.cgColor
        rippleLayer.opacity = 0.6

        let duration = 0.4

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 0.2
        scaleAnim.toValue = 1
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeIn)
        scaleAnim.duration = duration

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = 0.6
        opacityAnim.timingFunction = CAMediaTimingFunction(name: .easeIn)
        opacityAnim.duration = duration

        let groupAnim = CAAnimationGroup()
        groupAnim.animations = [scaleAnim, opacityAnim]
        groupAnim.duration = duration
        rippleLayer.add(groupAnim, forKey: nil)

        return rippleLayer
    }
}
