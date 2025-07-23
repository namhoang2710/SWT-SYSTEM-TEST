//
//  ActionModalPresentable.swift
//  ios-ui-components
//
//  Created by Duy Le on 18/06/2021.
//

import UIKit

/**
 This is the configuration object for a view controller
 that will be presented using the ActionModal transition.

 Usage:
 ```
 extension YourViewController: ActionModalPresentable {
    func shouldRoundTopCorners: Bool { return false }
 }
 ```
 */
public protocol TymeXActionModalPresentable: AnyObject {

    /**
     The presentation motion configuration
     */
    var presentMotionConfig: AnimationConfiguration { get }

    /**
     The dismissal motion configuration
     */
    var dismissalMotionConfig: AnimationConfiguration { get }

    /**
     The scroll view embedded in the view controller.
     Setting this value allows for seamless transition scrolling between the embedded scroll view
     and the action modal container view.
     */
    var actionScrollable: UIScrollView? { get }

    /**
     The offset between the top of the screen and the top of the action modal container view.

     Default value is the topLayoutGuide.length + 21.0.
     */
    var mxTopOffset: CGFloat { get }

    /**
     The height of the action modal container view
     when in the shortForm presentation state.

     This value is capped to .max, if provided value exceeds the space available.

     Default value is the longFormHeight.
     */
    var mxShortFormHeight: TymeXActionModalHeight { get }

    /**
     The height of the action modal container view
     when in the longForm presentation state.
     
     This value is capped to .max, if provided value exceeds the space available.

     Default value is .max.
     */
    var mxLongFormHeight: TymeXActionModalHeight { get }

    /**
     The height of the action modal container view
     when in the loadingForm presentation state.
     
     This value is capped to .max, if provided value exceeds the space available.

     Default value is .max.
     */
    var mxLoadingFormHeight: TymeXActionModalHeight { get }

    /**
     The corner radius used when `shouldRoundTopCorners` is enabled.

     Default Value is 30.0.
     */
    var mxCornerRadius: CGFloat { get }

    /**
     The background view color.

     - Note: This is only utilized at the very start of the transition.

     Default Value is black with alpha component 0.85.
    */
    var mxActionModalBackgroundColor: UIColor { get }

    /**
     The drag indicator view color.

     Default value is white.
    */
    var mxDragIndicatorBackgroundColor: UIColor { get }

    /**
     We configure the actionScrollable's scrollIndicatorInsets interally so override this value
     to set custom insets.

     - Note: Use `actionModalSetNeedsLayoutUpdate()` when updating insets.
     */
    var mxScrollIndicatorInsets: UIEdgeInsets { get }

    /**
     A flag to determine if scrolling should be limited to the longFormHeight.
     Return false to cap scrolling at .max height.

     Default value is true.
     */
    var mxAnchorModalToLongForm: Bool { get }

    /**
     A flag to determine if scrolling should seamlessly transition from the action modal container view to
     the embedded scroll view once the scroll limit has been reached.

     Default value is false. Unless a scrollView is provided and the content height exceeds the longForm height.
     */
    var mxAllowsExtendedActionScrolling: Bool { get }

    /**
     A flag to determine if dismissal should be initiated when swiping down on the presented view.

     Return false to fallback to the short form state instead of dismissing.

     Default value is true.
     */
    var mxAllowsDragToDismiss: Bool { get }

    /**
     A flag to determine if dismissal should be initiated when tapping on the dimmed background view.

     Default value is true.
     */
    var mxAllowsTapToDismiss: Bool { get }

    /**
     A flag to toggle user interactions on the container view.

     - Note: Return false to forward touches to the presentingViewController.

     Default is true.
    */
    var mxIsUserInteractionEnabled: Bool { get }

    /**
     A flag to determine if haptic feedback should be enabled during presentation.

     Default value is true.
     */
    var mxIsHapticFeedbackEnabled: Bool { get }

    /**
     A flag to determine if the top corners should be rounded.

     Default value is true.
     */
    var mxShouldRoundTopCorners: Bool { get }

    /**
     A flag to determine if a drag indicator should be shown
     above the action modal container view.

     Default value is true.
     */
    var mxShowDragIndicator: Bool { get }

    /**
     A custom indicator view, not effect when shouldRoundTopCorners is true
     above the action modal container view.

     Default value is nil.
     */
    var mxCustomDragIndicatorView: UIView? { get }

    /**
     Asks the delegate if the action modal should respond to the action modal gesture recognizer.
     
     Return false to disable movement on the action modal but maintain gestures on the presented view.

     Default value is true.
     */
    func mxShouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool

    /**
     Notifies the delegate when the pan modal gesture recognizer state is either
     `began` or `changed`. This method gives the delegate a chance to prepare
     for the gesture recognizer state change.

     For example, when the action modal view is about to scroll.

     Default value is an empty implementation.
     */
    func mxWillRespond(to panModalGestureRecognizer: UIPanGestureRecognizer)

    /**
     Asks the delegate if the pan modal gesture recognizer should be prioritized.

     For example, you can use this to define a region
     where you would like to restrict where the pan gesture can start.

     If false, then we rely solely on the internal conditions of when a pan gesture
     should succeed or fail, such as, if we're actively scrolling on the scrollView.

     Default return value is false.
     */
    func mxShouldPrioritize(panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool

    /**
     Asks the delegate if the pan modal should transition to a new state.

     Default value is true.
     */
    func mxShouldTransition(to state: TymeXActionModalPresentationController.PresentationState) -> Bool

    /**
     Notifies the delegate that the action modal is about to transition to a new state.

     Default value is an empty implementation.
     */
    func mxWillTransition(to state: TymeXActionModalPresentationController.PresentationState)

    /**
     Notifies the delegate that the action modal is about to be dismissed.

     Default value is an empty implementation.
     */
    func mxActionModalWillDismiss()

    /**
     Notifies the delegate after the action modal is dismissed.

     Default value is an empty implementation.
     */
    func mxActionModalDidDismiss()
}
