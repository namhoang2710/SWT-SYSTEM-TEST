//
//  UIView+Animations.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 16/12/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public extension UIView {
    /// Animate view using `AnimationConfiguration`.
    class func mxAnimateBy(
        _ configuration: AnimationConfiguration,
        options: AnimationOptions = [],
        animations: @escaping TymeXAnimationBlock,
        completion: TymeXAnimationCompletion? = nil
    ) {
        UIView.mxAnimate(
            with: configuration.duration.value,
            delay: configuration.delay.value,
            options: options,
            timingFunction: configuration.motionEasing.caType,
            animations: animations,
            completion: completion
        )
    }

    /// AnimateKeyframes view using `AnimationConfiguration`.
    class func mxAnimateKeyframesBy(
        with configuration: AnimationConfiguration,
        options: KeyframeAnimationOptions = [],
        animations: @escaping TymeXAnimationBlock,
        completion: TymeXAnimationCompletion? = nil
    ) {
        UIView.mxAnimateKeyframes(
            with: configuration.duration.value,
            delay: configuration.delay.value,
            options: options,
            timingFunction: configuration.motionEasing.caType,
            animations: animations,
            completion: completion
        )
    }

    /// Perform a `UIView` transition with a `CAMediaTimingFunction`
    /// - Parameters:
    ///   - view: View to animate
    ///   - duration: Duration of animation
    ///   - delay: Delay after which to start the animation
    ///   - options: Animation options (curve options would probably be ignored)
    ///   - timingFunction: `CAMediaTimingFunction` to be used for animation interpolation
    ///   - animations: Closure in which animatable properties should be changed
    ///   - completion: Optional closure to be executed when animation finishes
    class func mxTransitionBy(
        _ configuration: AnimationConfiguration,
        for view: UIView,
        options: AnimationOptions = [],
        animations: @escaping TymeXAnimationBlock,
        completion: TymeXAnimationCompletion? = nil
    ) {
        CATransaction.mxPerform(
            withDuration: configuration.duration.value,
            timingFunction: configuration.motionEasing.caType) {
                UIView.transition(
                    with: view,
                    duration: configuration.duration.value,
                    options: options,
                    animations: animations,
                    completion: completion
                )
            } completion: {
                completion?(true)
            }
    }

}

extension UIView {
    /// Perform a `UIView` animation with a `CAMediaTimingFunction`
    /// - Parameters:
    ///   - duration: Duration of animation
    ///   - delay: Delay after which to start the animation
    ///   - options: Animation options (curve options would probably be ignored)
    ///   - timingFunction: `CAMediaTimingFunction` to be used for animation interpolation
    ///   - animations: Closure in which animatable properties should be changed
    ///   - completion: Optional closure to be executed when animation finishes
    private class func mxAnimate(
        with duration: TimeInterval,
        delay: TimeInterval,
        options: AnimationOptions,
        timingFunction: CAMediaTimingFunction,
        animations: @escaping TymeXAnimationBlock,
        completion: TymeXAnimationCompletion? = nil
    ) {
        CATransaction.mxPerform(
            withDuration: duration,
            timingFunction: timingFunction) {
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    options: options,
                    animations: animations
                )
            } completion: {
                completion?(true)
            }
    }

    /// Perform a `UIView` animateKeyframes with a `CAMediaTimingFunction`
    /// - Parameters:
    ///   - duration: Duration of animation
    ///   - delay: Delay after which to start the animation
    ///   - options: Animation options (curve options would probably be ignored)
    ///   - timingFunction: `CAMediaTimingFunction` to be used for animation interpolation
    ///   - animations: Closure in which animatable properties should be changed
    ///   - completion: Optional closure to be exectued when animation finishes
    private class func mxAnimateKeyframes(
        with duration: TimeInterval,
        delay: TimeInterval,
        options: KeyframeAnimationOptions,
        timingFunction: CAMediaTimingFunction,
        animations: @escaping TymeXAnimationBlock,
        completion: TymeXAnimationCompletion? = nil
    ) {
        CATransaction.mxPerform(
            withDuration: duration,
            timingFunction: timingFunction) {
                // animate selection
                UIView.animateKeyframes(
                    withDuration: duration,
                    delay: delay,
                    options: options,
                    animations: animations
                )
            } completion: {
                completion?(true)
            }
    }
}

extension UIView {
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func mxDoAnimation(
        _ animation: AnimationType,
        configuration: AnimationConfiguration,
        completion: @escaping () -> Void
    ) {
        switch animation {
        case let .slide(way, direction):
            mxSlide(way, direction: direction, configuration: configuration, completion: completion)
        case let .squeeze(way, direction):
            mxSqueeze(way, direction: direction, configuration: configuration, completion: completion)
        case let .squeezeFade(way, direction):
            mxSqueezeFade(way, direction: direction, configuration: configuration, completion: completion)
        case let .slideFade(way, direction):
            mxSlideFade(way, direction: direction, configuration: configuration, completion: completion)
        case let .fade(way):
            mxFade(way, configuration: configuration, completion: completion)
        case let .zoom(way):
            mxZoom(way, configuration: configuration, completion: completion)
        case let .zoomInvert(way):
            mxZoom(way, invert: true, configuration: configuration, completion: completion)
        case let .shake(repeatCount):
            mxShake(repeatCount: repeatCount, configuration: configuration, completion: completion)
        case let .pop(repeatCount):
            mxPop(repeatCount: repeatCount, configuration: configuration, completion: completion)
        case let .squash(repeatCount):
            mxSquash(repeatCount: repeatCount, configuration: configuration, completion: completion)
        case let .flip(axis):
            mxFlip(axis: axis, configuration: configuration, completion: completion)
        case let .morph(repeatCount):
            mxMorph(repeatCount: repeatCount, configuration: configuration, completion: completion)
        case let .flash(repeatCount):
            mxFlash(repeatCount: repeatCount, configuration: configuration, completion: completion)
        case let .wobble(repeatCount):
            mxWobble(repeatCount: repeatCount, configuration: configuration, completion: completion)
        case let .swing(repeatCount):
            mxSwing(repeatCount: repeatCount, configuration: configuration, completion: completion)
        case let .rotate(direction, repeatCount):
            mxRotate(direction: direction, repeatCount: repeatCount,
                     configuration: configuration, completion: completion)
        case let .moveBy(xValue, yValue):
            mxMoveBy(xValue: xValue, yValue: yValue, configuration: configuration, completion: completion)
        case let .scale(fromX, fromY, toX, toY):
            mxScale(
                fromX: fromX, fromY: fromY,
                toX: toX, toY: toY,
                configuration: configuration, completion: completion)
        case let .spin(repeatCount):
            mxSpin(repeatCount: repeatCount, configuration: configuration, completion: completion)
        case let .compound(animations, run):
            let animations = animations.filter {
                if case .none = $0 {
                    return false
                }
                return true
            }
            guard !animations.isEmpty else {
                completion()
                return
            }
            switch run {
            case .sequential:
                let launch = animations.reversed().reduce(completion) { result, animation in {
                    self.mxDoAnimation(animation, configuration: configuration, completion: result)
                }
                }
                launch()
            case .parallel:
                var finalized = 0
                let finalCompletion: () -> Void = {
                    finalized += 1
                    if finalized == animations.count {
                        completion()
                    }
                }
                for animation in animations {
                    self.mxDoAnimation(animation, configuration: configuration, completion: finalCompletion)
                }
            }
        case .none:
            break
        }
    }
}
