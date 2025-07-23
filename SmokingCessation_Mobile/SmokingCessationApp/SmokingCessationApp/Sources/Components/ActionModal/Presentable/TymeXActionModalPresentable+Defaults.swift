//
//  ActionModalPresentable+Defaults.swift
//  ios-ui-components
//
//  Created by Duy Le on 18/06/2021.
//

import UIKit

/**
 Default values for the ActionModalPresentable.
 */
public extension TymeXActionModalPresentable where Self: UIViewController {
    var mxTopOffset: CGFloat {
        let statusBarHeight = 44
        let defaultPaddingTopModalViewSuperView = 102
        return CGFloat(defaultPaddingTopModalViewSuperView - statusBarHeight)
    }

    var mxShortFormHeight: TymeXActionModalHeight {
        return mxLongFormHeight
    }

    var mxLongFormHeight: TymeXActionModalHeight {
        guard let scrollView = actionScrollable
            else { return .maxHeightDefault }

        // called once during presentation and stored
        scrollView.layoutIfNeeded()
        return .contentHeight(scrollView.contentSize.height)
    }

    var mxLoadingFormHeight: TymeXActionModalHeight {
        return mxLongFormHeight
    }

    var mxCornerRadius: CGFloat {
        return SmokingCessation.cornerRadius4
    }

    var mxActionModalBackgroundColor: UIColor {
        return SmokingCessation.colorBackgroundStaticDarkBase
    }

    var mxDragIndicatorBackgroundColor: UIColor {
        return UIColor.white
    }

    var mxScrollIndicatorInsets: UIEdgeInsets {
        let top = mxShouldRoundTopCorners ? mxCornerRadius : 0
        return UIEdgeInsets(top: CGFloat(top), left: 0, bottom: bottomLayoutOffset, right: 0)
    }

    var mxAnchorModalToLongForm: Bool {
        return true
    }

    var mxAllowsExtendedActionScrolling: Bool {
        guard let scrollView = actionScrollable
            else { return false }

        scrollView.layoutIfNeeded()
        return scrollView.contentSize.height > (scrollView.frame.height - bottomLayoutOffset)
    }

    var mxAllowsDragToDismiss: Bool {
        return true
    }

    var mxAllowsTapToDismiss: Bool {
        return false
    }

    var mxIsUserInteractionEnabled: Bool {
        return true
    }

    var mxIsHapticFeedbackEnabled: Bool {
        return true
    }

    var mxShouldRoundTopCorners: Bool {
        return mxIsActionModalPresented
    }

    var mxShowDragIndicator: Bool {
        return mxShouldRoundTopCorners
    }

    var mxCustomDragIndicatorView: UIView? {
        return nil
    }

    func mxShouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return true
    }

    func mxWillRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) {
        // it should be override later
    }

    func mxShouldTransition(to state: TymeXActionModalPresentationController.PresentationState) -> Bool {
        return true
    }

    func mxShouldPrioritize(panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return false
    }

    func mxWillTransition(to state: TymeXActionModalPresentationController.PresentationState) {
        // it should be override later
    }

    func mxActionModalWillDismiss() {
        // it should be override later
    }

    func mxActionModalDidDismiss() {
        // it should be override later
    }
}
