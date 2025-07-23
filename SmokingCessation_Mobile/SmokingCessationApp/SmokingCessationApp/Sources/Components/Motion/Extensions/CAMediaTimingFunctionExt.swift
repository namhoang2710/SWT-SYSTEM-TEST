//
//  CAMediaTimingFunctionExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import Foundation
import UIKit

extension CAMediaTimingFunction {
    static func mxMakeCAMediaTimingFunction(
        _ easing: TymeXMotionEasingTuple
    ) -> CAMediaTimingFunction {
        return CAMediaTimingFunction(
            controlPoints: Float(easing.p1x), Float(easing.p1y), Float(easing.p2x), Float(easing.p2x)
        )
    }
    // MARK: - TymeX: ()
    /// 0.6,0,0.4,1
    @nonobjc public static let mxMotionEasingDefault: CAMediaTimingFunction =
    mxMakeCAMediaTimingFunction(SmokingCessation.motionEasingDefault)

    /// 0.5,0,0.3,1
    @nonobjc public static let mxMotionEasingSlowDown: CAMediaTimingFunction =
    mxMakeCAMediaTimingFunction(SmokingCessation.motionEasingSlowDown)

    /// 0.3,0,0.8,0.15
    @nonobjc public static let mxMotionEasingSpeedUp: CAMediaTimingFunction =
    mxMakeCAMediaTimingFunction(SmokingCessation.motionEasingSpeedUp)
}

extension CAMediaTimingFunction {
    /// Return the control points of the timing function.
    public var mxControlPoints: ((x: Float, y: Float), (x: Float, y: Float)) {
        var cps = [Float](repeating: 0, count: 4)
        getControlPoint(at: 0, values: &cps[0])
        getControlPoint(at: 1, values: &cps[1])
        getControlPoint(at: 2, values: &cps[2])
        getControlPoint(at: 3, values: &cps[3])
        return ((cps[0], cps[1]), (cps[2], cps[3]))
    }
}

// swiftlint:disable:next large_tuple
typealias TymeXAnimationValues = (x: CGFloat, y: CGFloat, scaleX: CGFloat, scaleY: CGFloat)
// swiftlint:disable:next large_tuple
typealias TymeXMotionEasingTuple = (p1x: Double, p1y: Double, p2x: Double, p2y: Double)
public typealias TymeXCompletion = (() -> Void)
public typealias TymeXBoolCompletion = ((Bool) -> Void)
public typealias TymeXAnimationTuple = (type: AnimationType, configuration: AnimationConfiguration)
public typealias TymeXAnimationCompletion = ((Bool) -> Void)
public typealias TymeXAnimationBlock = () -> Void
