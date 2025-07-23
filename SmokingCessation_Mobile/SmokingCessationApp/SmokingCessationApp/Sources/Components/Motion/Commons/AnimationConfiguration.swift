//
//  AnimationConfiguration.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import UIKit

public class AnimationConfiguration {
    public let duration: AnimationDuration
    public let delay: AnimationDelay
    public let force: CGFloat
    public let motionEasing: MXMotionEasing

    public init(
        duration: AnimationDuration,
        delay: AnimationDelay = .undefined,
        motionEasing: MXMotionEasing,
        force: CGFloat = 1.0
    ) {
        self.duration = duration
        self.delay = delay
        self.motionEasing = motionEasing
        self.force = force
    }
}
