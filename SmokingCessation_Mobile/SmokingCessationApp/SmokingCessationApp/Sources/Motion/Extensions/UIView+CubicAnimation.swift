//
//  UIView+CubicAnimation.swift
//  TymeXUIComponent
//
//  Created by Tung Nguyen on 07/08/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public extension UIView {
    /// Animate view using `AnimationConfiguration`.
    class func mxCubicAnimateBy(
        _ configuration: AnimationConfiguration,
        options: AnimationOptions = [],
        animations: @escaping TymeXAnimationBlock,
        completion: TymeXAnimationCompletion? = nil
    ) {
        UIView.mxCubicAnimate(
            with: configuration.duration.value,
            delay: configuration.delay.value,
            options: options,
            cubicParam: configuration.motionEasing.cubicTimingParameters,
            animations: animations,
            completion: completion)
    }

    /// Perform a `UIView` animation with a `UICubicTimingParameters`
    /// - Parameters:
    ///   - duration: Duration of animation
    ///   - delay: Delay after which to start the animation
    ///   - options: Animation options (curve options would probably be ignored)
    ///   - cubicParam: `UICubicTimingParameters` to be used for animation interpolation
    ///   - animations: Closure in which animatable properties should be changed
    ///   - completion: Optional closure to be executed when animation finishes
    private class func mxCubicAnimate(
        with duration: TimeInterval,
        delay: TimeInterval,
        options: AnimationOptions,
        cubicParam: UICubicTimingParameters,
        animations: @escaping TymeXAnimationBlock,
        completion: TymeXAnimationCompletion? = nil
    ) {
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: cubicParam)
        animator.addAnimations {
            animations()
        }
        animator.startAnimation()
        animator.addCompletion { _ in
            completion?(true)
        }
    }
}
