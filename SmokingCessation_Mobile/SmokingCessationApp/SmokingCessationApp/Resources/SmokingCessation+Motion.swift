//
//  SmokingCessation+Motion.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import Foundation

public extension SmokingCessation {
    /// 50ms
    static let motionDelay1: Double = 50

    /// 100ms
    static let motionDelay2: Double = 100

    /// 150ms
    static let motionDelay3: Double = 150

    /// 250ms
    static let motionDelay4: Double = 250

    /// 350ms
    static let motionDelay5: Double = 350

    /// 450ms
    static let motionDelay6: Double = 450

    /// 1000ms
    static let motionDelay7: Double = 1000

    /// 100ms
    static let motionDuration1: Double = 100

    /// 150ms
    static let motionDuration2: Double = 150

    /// 250ms
    static let motionDuration3: Double = 250

    /// 350ms
    static let motionDuration4: Double = 350

    /// 450ms
    static let motionDuration5: Double = 450

    /// 1000ms
    static let motionDuration6: Double = 1000

    /// 0.6,0,0.4,1
    static let motionEasingDefault: (p1x: Double, p1y: Double, p2x: Double, p2y: Double) = (0.6,0,0.4,1)

    /// 0.5,0,0.3,1
    static let motionEasingSlowDown: (p1x: Double, p1y: Double, p2x: Double, p2y: Double) = (0.5,0,0.3,1)

    /// 0.3,0,0.8,0.15
    static let motionEasingSpeedUp: (p1x: Double, p1y: Double, p2x: Double, p2y: Double) = (0.3,0,0.8,0.15)
}
