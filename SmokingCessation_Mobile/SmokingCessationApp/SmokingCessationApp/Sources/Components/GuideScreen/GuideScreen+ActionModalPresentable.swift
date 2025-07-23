//
//  GuideScreen+ActionModalPresentable.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

// MARK: - ActionModalPresentable
extension GuideScreen: TymeXActionModalPresentable {
    public var presentMotionConfig: AnimationConfiguration {
        return AnimationConfiguration(
            duration: .duration5,
            delay: .undefined,
            motionEasing: .motionEasingSlowDown
        )
    }

    public var dismissalMotionConfig: AnimationConfiguration {
        return AnimationConfiguration(
            duration: .duration3,
            delay: .undefined,
            motionEasing: .motionEasingSpeedUp
        )
    }

    public var actionScrollable: UIScrollView? {
        scrollView.contentInset.bottom = 0
        return scrollView

    }

    private func ensureLayoutIsUpToDate() {
           view.setNeedsLayout()
           view.layoutIfNeeded()
           scrollView.layoutIfNeeded()
    }

    private var computedModalHeight: TymeXActionModalHeight {
        guard guideScreenType == .modal else {
            return .contentHeight(view.frame.height)
        }
        ensureLayoutIsUpToDate()
        let dockHeight = buttonDock?.bounds.height ?? 0
        let total = scrollView.contentSize.height + dockHeight
        return .contentHeight(total)
    }

    public var mxShortFormHeight: TymeXActionModalHeight {
        computedModalHeight
    }

    public var mxLongFormHeight: TymeXActionModalHeight {
        computedModalHeight
    }

    public var mxActionModalBackgroundColor: UIColor {
        return .lightGray
    }

    public var mxShouldRoundTopCorners: Bool {
        return true
    }

    public var mxShowDragIndicator: Bool {
        return isShowDragIndicator
    }

    public var mxAllowsDragToDismiss: Bool {
        return isShowDragIndicator
    }

    public var mxAnchorModalToLongForm: Bool {
        return true
    }

    public var mxIsUserInteractionEnabled: Bool {
        return true
    }

    public var mxIsHapticFeedbackEnabled: Bool {
        return false
    }
}
