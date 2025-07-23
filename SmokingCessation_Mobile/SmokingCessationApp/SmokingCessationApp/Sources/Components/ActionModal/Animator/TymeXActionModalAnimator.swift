//
//  ActionModalAnimator.swift
//  ios-ui-components
//
//  Created by Duy Le on 18/06/2021.
//

import UIKit

/**
 Helper animation function to keep animations consistent.
 */
struct TymeXActionModalAnimator {
    static let defaultTransitionDuration: AnimationDuration = .duration5

    static func animateBy(
        presentable: TymeXActionModalPresentable?,
        transitionStyle: TymeXTransitionStyle,
        animations: @escaping TymeXAnimationBlock,
        completion: TymeXAnimationCompletion? = nil
    ) {
        guard let motionConfig = transitionStyle == .presentation
                ? presentable?.presentMotionConfig : presentable?.dismissalMotionConfig
        else { return }
        UIView.mxAnimateBy(motionConfig,
            animations: animations,
            completion: completion
        )
    }

    static func cubicAnimateBy(
        presentable: TymeXActionModalPresentable?,
        transitionStyle: TymeXTransitionStyle,
        animations: @escaping TymeXAnimationBlock,
        completion: TymeXAnimationCompletion? = nil
    ) {
        guard let motionConfig = transitionStyle == .presentation
                ? presentable?.presentMotionConfig : presentable?.dismissalMotionConfig
        else { return }
        UIView.mxCubicAnimateBy(motionConfig,
            animations: animations,
            completion: completion
        )
    }

}
