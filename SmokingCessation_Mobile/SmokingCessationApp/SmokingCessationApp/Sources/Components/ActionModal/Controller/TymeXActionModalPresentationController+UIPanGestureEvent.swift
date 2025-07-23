//
//  ActionModalPresentationController+UIPanGestureEvent.swift
//  TymeComponent
//
//  Created by Duy Le on 25/06/2021.
//

import UIKit

// MARK: - Pan Gesture Event Handler

internal extension TymeXActionModalPresentationController {

    /**
     The designated function for handling pan gesture events
     */
    @objc func didPanOnPresentedView(_ recognizer: UIPanGestureRecognizer) {

        guard
            shouldRespond(to: recognizer),
            let containerView = containerView
            else {
                recognizer.setTranslation(.zero, in: recognizer.view)
                return
        }

        switch recognizer.state {
        case .began, .changed:

            /**
             Respond accordingly to pan gesture translation
             */
            respond(to: recognizer)

            /**
             If presentedView is translated above the longForm threshold, treat as transition
             */
            if presentedView.frame.origin.y == anchoredYPosition && extendsActionScrolling {
                presentable?.mxWillTransition(to: .longForm)
            }

        default:

            /**
             Use velocity sensitivity value to restrict snapping
             */
            let velocity = recognizer.velocity(in: presentedView)

            if isVelocityWithinSensitivityRange(velocity.y) {

                /**
                 If velocity is within the sensitivity range,
                 transition to a presentation state or dismiss entirely.

                 This allows the user to dismiss directly from long form
                 instead of going to the short form state first.
                 */
                if velocity.y < 0 {
                    transition(to: .longForm)

                } else if (nearest(to: presentedView.frame.minY,
                                   inValues: [longFormYPosition, containerView.bounds.height]) == longFormYPosition
                            && presentedView.frame.minY < shortFormYPosition)
                            || presentable?.mxAllowsDragToDismiss == false {
                    transition(to: .shortForm)

                } else {
                    presentedViewController.dismiss(animated: true)
                }

            } else {

                /**
                 The `containerView.bounds.height` is used to determine
                 how close the presented view is to the bottom of the screen
                 */
                let position = nearest(to: presentedView.frame.minY,
                                       inValues: [containerView.bounds.height,
                                                  shortFormYPosition, longFormYPosition, loadingFormYPosition])

                if position == longFormYPosition {
                    transition(to: .longForm)
                } else if position == shortFormYPosition || presentable?.mxAllowsDragToDismiss == false {
                    transition(to: .shortForm)
                } else {
                    presentedViewController.dismiss(animated: true)
                }
            }
        }
    }

    /**
     Determine if the action modal should respond to the gesture recognizer.

     If the action modal is already being dragged & the delegate returns false, ignore until
     the recognizer is back to it's original state (.began)

     ⚠️ This is the only time we should be cancelling the pan modal gesture recognizer
     */
    func shouldRespond(to panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        guard
            presentable?.mxShouldRespond(to: panGestureRecognizer) == true ||
                !(panGestureRecognizer.state == .began || panGestureRecognizer.state == .cancelled)
            else {
                panGestureRecognizer.isEnabled = false
                panGestureRecognizer.isEnabled = true
                return false
        }
        return !shouldFail(panGestureRecognizer: panGestureRecognizer)
    }

    /**
     Communicate intentions to presentable and adjust subviews in containerView
     */
    func respond(to panGestureRecognizer: UIPanGestureRecognizer) {
        presentable?.mxWillRespond(to: panGestureRecognizer)

        var yDisplacement = panGestureRecognizer.translation(in: presentedView).y

        /**
         If the presentedView is not anchored to long form, reduce the rate of movement
         above the threshold
         */
        if presentedView.frame.origin.y < longFormYPosition {
            yDisplacement /= 2.0
        }
        adjust(toYPosition: presentedView.frame.origin.y + yDisplacement)

        panGestureRecognizer.setTranslation(.zero, in: presentedView)
    }

    /**
     Determines if we should fail the gesture recognizer based on certain conditions

     We fail the presented view's pan gesture recognizer if we are actively scrolling on the scroll view.
     This allows the user to drag whole view controller from outside scrollView touch area.

     Unfortunately, cancelling a gestureRecognizer means that we lose the effect of transition scrolling
     from one view to another in the same pan gesture so don't cancel
     */
    func shouldFail(panGestureRecognizer: UIPanGestureRecognizer) -> Bool {

        /**
         Allow api consumers to override the internal conditions &
         decide if the pan gesture recognizer should be prioritized.

         ⚠️ This is the only time we should be cancelling the actionScrollable recognizer,
         for the purpose of ensuring we're no longer tracking the scrollView
         */
        guard !shouldPrioritize(panGestureRecognizer: panGestureRecognizer) else {
            presentable?.actionScrollable?.panGestureRecognizer.isEnabled = false
            presentable?.actionScrollable?.panGestureRecognizer.isEnabled = true
            return false
        }

        guard
            isPresentedViewAnchored,
            let scrollView = presentable?.actionScrollable,
            scrollView.contentOffset.y > 0
            else {
                return false
        }

        let loc = panGestureRecognizer.location(in: presentedView)
        return (scrollView.frame.contains(loc) || scrollView.mxIsScrolling)
    }

    /**
     Determine if the presented view's panGestureRecognizer should be prioritized over
     embedded scrollView's panGestureRecognizer.
     */
    func shouldPrioritize(panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return panGestureRecognizer.state == .began &&
            presentable?.mxShouldPrioritize(panModalGestureRecognizer: panGestureRecognizer) == true
    }

    /**
     Check if the given velocity is within the sensitivity range
     */
    func isVelocityWithinSensitivityRange(_ velocity: CGFloat) -> Bool {
        return (abs(velocity) - (1000 * (1 - Constants.snapMovementSensitivity))) > 0
    }

    func snap(toYPosition yPos: CGFloat) {
        TymeXActionModalAnimator.cubicAnimateBy(
            presentable: presentable,
            transitionStyle: .presentation) { [weak self] in
            guard let self = self else { return }
            self.adjust(toYPosition: yPos)
            self.isPresentedViewAnimating = true
        } completion: { [weak self] didComplete in
            guard let self = self else { return }
            self.isPresentedViewAnimating = !didComplete
        }
    }

    /**
     Sets the y position of the presentedView & adjusts the backgroundView.
     */
    func adjust(toYPosition yPos: CGFloat) {
        presentedView.frame.origin.y = max(yPos, anchoredYPosition)

        guard presentedView.frame.origin.y > shortFormYPosition else {
            backgroundView.dimState = .max
            return
        }

        let yDisplacementFromShortForm = presentedView.frame.origin.y - shortFormYPosition

        /**
         Once presentedView is translated below shortForm, calculate yPos relative to bottom of screen
         and apply percentage to backgroundView alpha
         */
        backgroundView.dimState = .percent(1.0 - (yDisplacementFromShortForm / presentedView.frame.height))
    }

    /**
     Finds the nearest value to a given number out of a given array of float values

     - Parameters:
        - number: reference float we are trying to find the closest value to
        - values: array of floats we would like to compare against
     */
    func nearest(to number: CGFloat, inValues values: [CGFloat]) -> CGFloat {
        guard let nearestVal = values.min(by: { abs(number - $0) < abs(number - $1) })
            else { return number }
        return nearestVal
    }
}

// MARK: - UIGestureRecognizerDelegate

extension TymeXActionModalPresentationController: UIGestureRecognizerDelegate {

    /**
     Do not require any other gesture recognizers to fail
     */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    /**
     Allow simultaneous gesture recognizers only when the other gesture recognizer's view
     is the action scrollable view
     */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith
                                    otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.view == presentable?.actionScrollable
    }
}
