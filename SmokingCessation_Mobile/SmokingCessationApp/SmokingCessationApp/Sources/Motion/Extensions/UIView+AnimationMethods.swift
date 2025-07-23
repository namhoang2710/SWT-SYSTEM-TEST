//
//  UIView+AnimationMethods.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 25/10/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

enum TymeXAnimationKey {
    static let pop: String = "pop"
    static let squash: String = "squash"
    static let morph: String = "morph"
    static let wobble: String = "wobble"
    static let flash: String = "flash"
    static let squeeze: String = "squeeze"
    static let swing: String = "swing"
    static let moveTo: String = "moveTo"
    static let scale: String = "scale"
    static let spin: String = "spin"
    static let fade: String = "fade"
    static let shake: String = "shake"
    static let rotate: String = "rotate"
    static let animatePosition: String = "animate position"
    static let focusAnimation: String = "focus Animation"
}

// swiftlint:disable file_length
extension UIView {
    // MARK: - Animation methods
    func mxSlide(
        _ way: AnimationType.Way,
        direction: AnimationType.Direction,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        let values = mxComputeValues(
            way: way,
            direction: direction,
            configuration: configuration,
            shouldScale: false
        )
        switch way {
        case .in:
            mxAnimateIn(
                animationValues: values,
                alpha: 1,
                configuration: configuration,
                completion: completion
            )
        case .out:
            mxAnimateOut(
                animationValues: values,
                alpha: 1,
                configuration: configuration,
                completion: completion
            )
        }
    }

    func mxSqueeze(
        _ way: AnimationType.Way,
        direction: AnimationType.Direction,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        let values = mxComputeValues(
            way: way,
            direction: direction,
            configuration: configuration,
            shouldScale: true
        )
        switch way {
        case .in:
            mxAnimateIn(
                animationValues: values,
                alpha: 1,
                configuration: configuration,
                completion: completion)
        case .out:
            mxAnimateOut(animationValues: values, alpha: 1, configuration: configuration, completion: completion)
        }
    }

    func mxRotate(
        direction: AnimationType.RotationDirection,
        repeatCount: Int,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let animation = CABasicAnimation(keyPath: .rotation)
            animation.fromValue = direction == .cw ? 0 : CGFloat.pi * 2
            animation.toValue = direction == .cw  ? CGFloat.pi * 2 : 0
            animation.duration = configuration.duration.value
            animation.repeatCount = Float(repeatCount)
            animation.autoreverses = false
            animation.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            self.layer.add(animation, forKey: TymeXAnimationKey.rotate)
        }, completion: completion)
    }

    func mxSlideFade(
        _ way: AnimationType.Way,
        direction: AnimationType.Direction,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        let values = mxComputeValues(
            way: way,
            direction: direction,
            configuration: configuration,
            shouldScale: false
        )
        switch way {
        case .in:
            alpha = 0
            mxAnimateIn(
                animationValues: values,
                alpha: 1,
                configuration: configuration,
                completion: completion
            )
        case .out:
            mxAnimateOut(
                animationValues: values,
                alpha: 0,
                configuration: configuration,
                completion: completion
            )
        }
    }

    func mxFade(
        _ way: AnimationType.FadeWay,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        switch way {
        case .outIn:
            mxFadeOutIn(configuration: configuration, completion: completion)
        case .inOut:
            mxFadeInOut(configuration: configuration, completion: completion)
        case .in:
            alpha = 0
            mxAnimateIn(
                animationValues: TymeXAnimationValues(x: 0, y: 0, scaleX: 1, scaleY: 1),
                alpha: 1,
                configuration: configuration,
                completion: completion
            )
        case .out:
            alpha = 1
            mxAnimateOut(
                animationValues: TymeXAnimationValues(x: 0, y: 0, scaleX: 1, scaleY: 1),
                alpha: 0,
                configuration: configuration,
                completion: completion
            )
        }
    }

    func mxSqueezeFade(
        _ way: AnimationType.Way,
        direction: AnimationType.Direction,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        let values = mxComputeValues(
            way: way, direction: direction,
            configuration: configuration,
            shouldScale: true
        )
        switch way {
        case .in:
            alpha = 0
            mxAnimateIn(
                animationValues: values,
                alpha: 1,
                configuration: configuration,
                completion: completion
            )
        case .out:
            mxAnimateOut(
                animationValues: values,
                alpha: 0,
                configuration: configuration,
                completion: completion
            )
        }
    }

    func mxZoom(
        _ way: AnimationType.Way,
        invert: Bool = false,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        let toAlpha: CGFloat
        switch way {
        case .in where invert:
            let scale = configuration.force
            alpha = 0
            toAlpha = 1
            transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            mxAnimateIn(
                animationValues: TymeXAnimationValues(x: 0, y: 0, scaleX: scale / 2, scaleY: scale / 2),
                alpha: toAlpha,
                configuration: configuration,
                completion: completion
            )
        case .in:
            let scale = 2 * configuration.force
            alpha = 0
            toAlpha = 1
            mxAnimateIn(
                animationValues: TymeXAnimationValues(x: 0, y: 0, scaleX: scale, scaleY: scale),
                alpha: toAlpha,
                configuration: configuration,
                completion: completion
            )
        case .out:
            let scale = (invert ? 0.1 :  2) * configuration.force
            toAlpha = 0
            mxAnimateOut(
                animationValues: TymeXAnimationValues(x: 0, y: 0, scaleX: scale, scaleY: scale),
                alpha: toAlpha,
                configuration: configuration,
                completion: completion
            )
        }
    }

    func mxFlip(
        axis: AnimationType.Axis,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        let scaleX: CGFloat
        let scaleY: CGFloat
        switch axis {
        case .x:
            scaleX = 1
            scaleY = -1
        case .y:
            scaleX = -1
            scaleY = 1
        }
        mxAnimateIn(
            animationValues: TymeXAnimationValues(x: 0, y: 0, scaleX: scaleX, scaleY: scaleY),
            alpha: 1,
            configuration: configuration,
            completion: completion
        )
    }

    func mxShake(
        repeatCount: Int,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let animation = CAKeyframeAnimation(keyPath: .positionX)
            animation.values = [0, 30 * configuration.force, -30 * configuration.force, 30 * configuration.force, 0]
            animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            animation.timingFunctionType = configuration.motionEasing ?? .undefined
            animation.duration = configuration.duration.value
            animation.isAdditive = true
            animation.repeatCount = Float(repeatCount)
            animation.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            self.layer.add(animation, forKey: TymeXAnimationKey.shake)
        }, completion: completion)
    }

    func mxPop(
        repeatCount: Int,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let animation = CAKeyframeAnimation(keyPath: .scale)
            animation.values = [0, 0.2 * configuration.force, -0.2 * configuration.force, 0.2 * configuration.force, 0]
            animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            animation.timingFunctionType = configuration.motionEasing ?? .undefined
            animation.duration = configuration.duration.value
            animation.isAdditive = true
            animation.repeatCount = Float(repeatCount)
            animation.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            self.layer.add(animation, forKey: TymeXAnimationKey.pop)
        }, completion: completion)
    }

    func mxSquash(
        repeatCount: Int,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let squashX = CAKeyframeAnimation(keyPath: .scaleX)
            squashX.values = [1, 1.5 * configuration.force, 0.5, 1.5 * configuration.force, 1]
            squashX.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            squashX.timingFunctionType = configuration.motionEasing ?? .undefined

            let squashY = CAKeyframeAnimation(keyPath: .scaleY)
            squashY.values = [1, 0.5, 1, 0.5, 1]
            squashY.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            squashY.timingFunctionType = configuration.motionEasing ?? .undefined
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [squashX, squashY]
            animationGroup.duration = configuration.duration.value
            animationGroup.repeatCount = Float(repeatCount)
            animationGroup.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            self.layer.add(animationGroup, forKey: TymeXAnimationKey.squash)
        }, completion: completion)
    }

    func mxMorph(
        repeatCount: Int,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let morphX = CAKeyframeAnimation(keyPath: .scaleX)
            morphX.values = [1, 1.3 * configuration.force, 0.7, 1.3 * configuration.force, 1]
            morphX.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            morphX.timingFunctionType = configuration.motionEasing ?? .undefined
            let morphY = CAKeyframeAnimation(keyPath: .scaleY)
            morphY.values = [1, 0.7, 1.3 * configuration.force, 0.7, 1]
            morphY.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            morphY.timingFunctionType = configuration.motionEasing ?? .undefined

            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [morphX, morphY]
            animationGroup.duration = configuration.duration.value
            animationGroup.repeatCount = Float(repeatCount)
            animationGroup.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            self.layer.add(animationGroup, forKey: TymeXAnimationKey.morph)
        }, completion: completion)
    }

    func mxSqueeze(
        repeatCount: Int,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let squeezeX = CAKeyframeAnimation(keyPath: .scaleX)
            squeezeX.values = [1, 1.5 * configuration.force, 0.5, 1.5 * configuration.force, 1]
            squeezeX.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            squeezeX.timingFunctionType = configuration.motionEasing ?? .undefined
            let squeezeY = CAKeyframeAnimation(keyPath: .scaleY)
            squeezeY.values = [1, 0.5, 1, 0.5, 1]
            squeezeY.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            squeezeY.timingFunctionType = configuration.motionEasing ?? .undefined
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [squeezeX, squeezeY]
            animationGroup.duration = configuration.duration.value
            animationGroup.repeatCount = Float(repeatCount)
            animationGroup.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            self.layer.add(animationGroup, forKey: TymeXAnimationKey.squeeze)
        }, completion: completion)
    }

    func mxFlash(
        repeatCount: Int,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let animation = CABasicAnimation(keyPath: .opacity)
            animation.fromValue = 1
            animation.toValue = 0
            animation.duration = configuration.duration.value
            animation.repeatCount = Float(repeatCount) * 2.0
            animation.autoreverses = true
            animation.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            self.layer.add(animation, forKey: TymeXAnimationKey.flash)
        }, completion: completion)
    }

    func mxWobble(
        repeatCount: Int,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let rotation = CAKeyframeAnimation(keyPath: .rotation)
            rotation.values = [0, 0.3 * configuration.force, -0.3 * configuration.force, 0.3 * configuration.force, 0]
            rotation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            rotation.isAdditive = true
            let positionX = CAKeyframeAnimation(keyPath: .positionX)
            positionX.values = [0, 30 * configuration.force, -30 * configuration.force, 30 * configuration.force, 0]
            positionX.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            positionX.timingFunctionType = configuration.motionEasing ?? .undefined
            positionX.isAdditive = true
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [rotation, positionX]
            animationGroup.duration = configuration.duration.value
            animationGroup.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            animationGroup.repeatCount = Float(repeatCount)
            self.layer.add(animationGroup, forKey: TymeXAnimationKey.wobble)
        }, completion: completion)
    }

    func mxSwing(
        repeatCount: Int,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let animation = CAKeyframeAnimation(keyPath: .rotation)
            animation.values = [0, 0.3 * configuration.force, -0.3 * configuration.force, 0.3 * configuration.force, 0]
            animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            animation.duration = configuration.duration.value
            animation.isAdditive = true
            animation.repeatCount = Float(repeatCount)
            animation.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            self.layer.add(animation, forKey: TymeXAnimationKey.swing)
        }, completion: completion)
    }

    func mxMoveBy(
        xValue: Double,
        yValue: Double,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        if xValue.isNaN && yValue.isNaN {
            return
        }
        let position = self.center
        var xToMove: CGFloat
        if xValue.isNaN {
            xToMove = position.x
        } else {
            xToMove = position.x + CGFloat(xValue)
        }
        var yToMove: CGFloat
        if yValue.isNaN {
            yToMove = position.y
        } else {
            yToMove = position.y + CGFloat(yValue)
        }
        let path = UIBezierPath()
        path.move(to: position)
        path.addLine(to: CGPoint(x: xToMove, y: yToMove))
        mxAnimatePosition(
            path: path,
            configuration: configuration,
            completion: completion
        )
    }

    func mxScale(
        fromX: Double,
        fromY: Double,
        toX: Double,
        toY: Double,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        if fromX.isNaN || fromY.isNaN || toX.isNaN || toY.isNaN {
            return
        }
        mxLayerScale(
            fromX: fromX,
            fromY: fromY,
            toX: toX,
            toY: toY,
            configuration: configuration,
            completion: completion
        )
    }

    private func mxSpringScale(
        fromX: Double,
        fromY: Double,
        toX: Double,
        toY: Double,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        transform = CGAffineTransform(scaleX: CGFloat(fromX), y: CGFloat(fromY))
        UIView.mxAnimateBy(configuration, animations: {
            self.transform = CGAffineTransform(scaleX: CGFloat(toX), y: CGFloat(toY))
        }, completion: { completed in
            if completed {
                completion?()
            }
        })
    }

    func mxSpin(
        repeatCount: Int,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let rotationX = CABasicAnimation(keyPath: .rotationX)
            rotationX.toValue = CGFloat.pi * 2
            rotationX.fromValue = 0
            rotationX.timingFunctionType = configuration.motionEasing ?? .undefined

            let rotationY = CABasicAnimation(keyPath: .rotationY)
            rotationY.toValue = CGFloat.pi * 2
            rotationY.fromValue = 0
            rotationY.timingFunctionType = configuration.motionEasing ?? .undefined

            let rotationZ = CABasicAnimation(keyPath: .rotationZ)
            rotationZ.toValue = CGFloat.pi * 2
            rotationZ.fromValue = 0
            rotationZ.timingFunctionType = configuration.motionEasing ?? .undefined

            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [rotationX, rotationY, rotationZ]
            animationGroup.duration = configuration.duration.value
            animationGroup.repeatCount = Float(repeatCount)
            animationGroup.beginTime = CACurrentMediaTime() + configuration.delay.value
            self.layer.add(animationGroup, forKey: TymeXAnimationKey.spin)
        }, completion: completion)
    }
}

extension UIView {
    func mxFadeOutIn(
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let animation = CABasicAnimation(keyPath: .opacity)
            animation.fromValue = 1
            animation.toValue = 0
            animation.timingFunctionType = configuration.motionEasing ?? .undefined
            animation.duration = configuration.duration.value
            animation.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            animation.autoreverses = true
            self.layer.add(animation, forKey: TymeXAnimationKey.fade)
        }, completion: completion)
    }

    func mxFadeInOut(
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let animation = CABasicAnimation(keyPath: .opacity)
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunctionType = configuration.motionEasing ?? .undefined
            animation.duration = configuration.duration.value
            animation.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            animation.autoreverses = true
            animation.isRemovedOnCompletion = false
            self.layer.add(animation, forKey: TymeXAnimationKey.fade)
        }, completion: {
            self.alpha = 0
            completion?()
        })
    }

    func mxMoveTo(
        xValue: CGFloat,
        yValue: CGFloat,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        UIView.mxAnimateBy(configuration, animations: {
            self.frame = CGRect(
                x: xValue,
                y: yValue,
                width: self.frame.size.width,
                height: self.frame.size.height
            )
        }, completion: { completed in
            if completed {
                completion?()
            }
        })
    }

    func mxAnimatePosition(
        path: UIBezierPath,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let animation = CAKeyframeAnimation(keyPath: .position)
            animation.timingFunctionType = configuration.motionEasing ?? .undefined
            animation.duration = configuration.duration.value
            animation.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            animation.path = path.cgPath
            self.layer.add(animation, forKey: TymeXAnimationKey.animatePosition)
        }, completion: completion)
    }

    func mxAnimateIn(
        animationValues: TymeXAnimationValues,
        alpha: CGFloat,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        let translate = CGAffineTransform(translationX: animationValues.x, y: animationValues.y)
        let scale = CGAffineTransform(scaleX: animationValues.scaleX, y: animationValues.scaleY)
        let translateAndScale = translate.concatenating(scale)
        transform = translateAndScale
        UIView.mxAnimateBy(configuration, animations: {
            self.transform = .identity
            self.alpha = alpha
        }, completion: { completed in
            if completed {
                completion?()
            }
        })
    }

    func mxAnimateOut(
        animationValues: TymeXAnimationValues,
        alpha: CGFloat,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        let translate = CGAffineTransform(translationX: animationValues.x, y: animationValues.y)
        let scale = CGAffineTransform(scaleX: animationValues.scaleX, y: animationValues.scaleY)
        let translateAndScale = translate.concatenating(scale)
        UIView.mxAnimateBy(configuration, animations: {
            self.transform = translateAndScale
            self.alpha = alpha
        }, completion: { completed in
            if completed {
                completion?()
            }
        })
    }

    func mxLayerScale(
        fromX: Double,
        fromY: Double,
        toX: Double,
        toY: Double,
        configuration: AnimationConfiguration,
        completion: TymeXCompletion? = nil
    ) {
        CALayer.mxAnimate({
            let scaleX = CAKeyframeAnimation(keyPath: .scaleX)
            scaleX.values = [fromX, toX]
            scaleX.keyTimes = [0, 1]
            scaleX.timingFunctionType = configuration.motionEasing ?? .undefined
            let scaleY = CAKeyframeAnimation(keyPath: .scaleY)
            scaleY.values = [fromY, toY]
            scaleY.keyTimes = [0, 1]
            scaleY.timingFunctionType = configuration.motionEasing ?? .undefined
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [scaleX, scaleY]
            animationGroup.duration = configuration.duration.value
            animationGroup.beginTime = self.layer.mxCurrentMediaTime + configuration.delay.value
            self.layer.add(animationGroup, forKey: TymeXAnimationKey.scale)
        }, completion: completion)
    }

    func mxComputeValues(
        way: AnimationType.Way,
        direction: AnimationType.Direction,
        configuration: AnimationConfiguration,
        shouldScale: Bool
    ) -> TymeXAnimationValues {
        let scale = 3 * configuration.force
        var scaleX: CGFloat = 1
        var scaleY: CGFloat = 1
        var frame: CGRect
        if let window = window {
            frame = window.convert(self.frame, to: window)
        } else {
            frame = self.frame
        }
        var xValue: CGFloat = 0
        var yValue: CGFloat = 0
        switch (way, direction) {
        case (.in, .left), (.out, .right):
            xValue = mxScreenSize.width - frame.minX
        case (.in, .right), (.out, .left):
            xValue = -frame.maxX
        case (.in, .up), (.out, .down):
            yValue = mxScreenSize.height - frame.minY
        case (.in, .down), (.out, .up):
            yValue = -frame.maxY
        }
        xValue *= configuration.force
        yValue *= configuration.force
        if shouldScale && direction.isVertical() {
            scaleY = scale
        } else if shouldScale {
            scaleX = scale
        }
        return (x: xValue, y: yValue, scaleX: scaleX, scaleY: scaleY)
    }

    var mxScreenSize: CGSize {
        return window?.screen.bounds.size ?? .zero
    }
}
// swiftlint:enable file_length

