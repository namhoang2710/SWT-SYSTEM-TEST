//
//  ActionModalPresentable+UIViewController.swift
//  ios-ui-components
//
//  Created by Duy Le on 18/06/2021.
//

import UIKit

/**
 Extends ActionModalPresentable with helper methods
 when the conforming object is a UIViewController
 */
public extension TymeXActionModalPresentable where Self: UIViewController {
    /**
     For Presentation, the object must be a UIViewController & confrom to the ActionModalPresentable protocol.
     */
    typealias TymeXLayoutType = UIViewController & TymeXActionModalPresentable

    /**
     A function wrapper over the `transition(to state: ActionModalPresentationController.PresentationState)`
     function in the ActionModalPresentationController.
     */
    func mxActionModalTransition(to state: TymeXActionModalPresentationController.PresentationState) {
        presentedVC?.transition(to: state)
    }

    /**
     A function wrapper over the `transition(to state: ActionModalPresentationController.PresentationState)`
     function in the ActionModalPresentationController.
     */
    func mxActionModalInitialPresentationState(with state: TymeXActionModalPresentationController.PresentationState) {
        presentedVC?.presentationState = state
    }

    /**
     A function wrapper over the `setNeedsLayoutUpdate()`
     function in the ActionModalPresentationController.

     - Note: This should be called whenever any of the values for the ActionModalPresentable protocol are changed.
     */
    func mxActionModalSetNeedsLayoutUpdate() {
        presentedVC?.setNeedsLayoutUpdate()
    }

    func mxActionModalSetNeedsLayoutUpdateResetYPos() {

        presentedVC?.setNeedsLayoutUpdateResetYPos(state: .shortForm)
    }
    /**
     Operations on the scroll view, such as content height changes,
     or when inserting/deleting rows can cause the action modal to jump,
     caused by the action modal responding to content offset changes.

     To avoid this, you can call this method to perform scroll view updates,
     with scroll observation temporarily disabled.
     */
    func mxActionModalPerformUpdates(_ updates: () -> Void) {
        presentedVC?.performUpdates(updates)
    }

    /**
     A function wrapper over the animate function in ActionModalAnimator.

     This can be used for animation consistency on views within the presented view controller.
     */
    func mxActionModalAnimate(
        _ animationBlock: @escaping TymeXAnimationBlock,
        _ completion: TymeXAnimationCompletion? = nil
    ) {
        TymeXActionModalAnimator.animateBy(
            presentable: self,
            transitionStyle: .presentation,
            animations: animationBlock,
            completion: completion
        )
    }

}
