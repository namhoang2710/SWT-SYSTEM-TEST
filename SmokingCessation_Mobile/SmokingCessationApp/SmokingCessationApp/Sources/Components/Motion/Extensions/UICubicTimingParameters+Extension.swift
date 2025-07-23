//
//  UICubicTimingParameters+Extension.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import UIKit

extension UICubicTimingParameters {
    static func mxMakeUICubicTimingParameters(
        _ easing: TymeXMotionEasingTuple
    ) -> UICubicTimingParameters {
        return UICubicTimingParameters(
            controlPoint1: CGPoint(x: Double(easing.p1x), y: Double(easing.p1y)),
            controlPoint2: CGPoint(x: Double(easing.p2x), y: Double(easing.p2y))
        )
    }

    /// 0.6,0,0.4,1
    @nonobjc public static let mxCubicTimingParametersDefault: UICubicTimingParameters =
    mxMakeUICubicTimingParameters(SmokingCessation.motionEasingDefault)

    /// 0.5,0,0.3,1
    @nonobjc public static let mxCubicTimingParametersSlowDown: UICubicTimingParameters =
    mxMakeUICubicTimingParameters(SmokingCessation.motionEasingSlowDown)

    /// 0.3,0,0.8,0.15
    @nonobjc public static let mxCubicTimingParametersSpeedUp: UICubicTimingParameters =
    mxMakeUICubicTimingParameters(SmokingCessation.motionEasingSpeedUp)
}
