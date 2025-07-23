//
//  ActionModalBaseViewController.swift
//  TymeXUIComponent
//
//  Created by Tung Nguyen on 24/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

open class TymeXActionModalBaseViewController: UIViewController, TymeXActionModalPresentable {

    // MARK: - ActionModalPresentable

    public var presentMotionConfig: AnimationConfiguration {
        return AnimationConfiguration(
            duration: .duration4,
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
        return nil
    }

    public var mxShortFormHeight: TymeXActionModalHeight {
        return .contentHeight(view.frame.size.height)
    }

    public var mxLongFormHeight: TymeXActionModalHeight {
        return .maxHeightDefault
    }

    public var mxActionModalBackgroundColor: UIColor {
        return SmokingCessation.colorBackgroundDarkBase.withAlphaComponent(0.9)
    }

    public var mxShouldRoundTopCorners: Bool {
        return false
    }

    public var mxShowDragIndicator: Bool {
        return false
    }

    public var mxAllowsDragToDismiss: Bool {
        return false
    }

    public var mxAnchorModalToLongForm: Bool {
        return false
    }

    public var mxIsUserInteractionEnabled: Bool {
        return true
    }

	public var mxAllowsTapToDismiss: Bool {
		return false
	}

    public func mxShouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return mxAllowsDragToDismiss || mxShowDragIndicator
    }

    public func applyModalBorderToContentView(_ view: UIView) {
        view.mxCornerRadius = SmokingCessation.cornerRadius5
    }
}
