//
//  ActionModalPresentationAnimator.swift
//  ios-ui-components
//
//  Created by Duy Le on 18/06/2021.
//

import UIKit

/**
 Handles the animation of the presentedViewController as it is presented or dismissed.

 This is a vertical animation that
 - Animates up from the bottom of the screen
 - Dismisses from the top to the bottom of the screen

 This can be used as a standalone object for transition animation,
 but is primarily used in the ActionModalPresentationDelegate for handling action modal transitions.

 - Note: The presentedViewController can conform to ActionModalPresentable to adjust
 it's starting position through manipulating the shortFormHeight
 */

/**
 Enum representing the possible transition styles
 */
public enum TymeXTransitionStyle {
    case presentation
    case dismissal
}

public class TymeXActionModalPresentationAnimator: NSObject {
    // MARK: - Properties

    /**
     The transition style
     */
    private let transitionStyle: TymeXTransitionStyle

    /**
     Haptic feedback generator (during presentation)
     */
    private var feedbackGenerator: UISelectionFeedbackGenerator?

    // MARK: - Initializers

    required public init(transitionStyle: TymeXTransitionStyle) {
        self.transitionStyle = transitionStyle
        super.init()

        /**
         Prepare haptic feedback, only during the presentation state
         */
        if case .presentation = transitionStyle {
            feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator?.prepare()
        }
    }

    /**
     Animate presented view controller presentation
     */
    private func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {

        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from)
            else { return }

        let presentable = actionModalLayoutType(from: transitionContext)

        // Calls viewWillAppear and viewWillDisappear
        fromVC.beginAppearanceTransition(false, animated: true)

        // Presents the view in shortForm position, initially
        var yPos: CGFloat = presentable?.shortFormYPos ?? 0.0
        if presentable?.presentedVC?.presentationState == .loading {
            yPos = presentable?.loadingFormYPos ?? 0.0
        }
        // Use actionView as presentingView if it already exists within the containerView
        let actionView: UIView = transitionContext.containerView.mxActionContainerView ?? toVC.view

        // Move presented view offscreen (from the bottom)
        actionView.frame = transitionContext.finalFrame(for: toVC)
        actionView.frame.origin.y = transitionContext.containerView.frame.height

        // Haptic feedback
        if presentable?.mxIsHapticFeedbackEnabled == true {
            feedbackGenerator?.selectionChanged()
        }

        if let indicatorView = presentable?.presentedVC?.getIndicatorView() {
            indicatorView.alpha = 0
            TymeXActionModalAnimator.cubicAnimateBy(
                presentable: presentable,
                transitionStyle: .presentation) {
                    actionView.frame.origin.y = yPos
                } completion: { [weak self] didComplete in
                    guard let self = self else { return }
                    // Calls viewDidAppear and viewDidDisappear
                    fromVC.endAppearanceTransition()
                    transitionContext.completeTransition(didComplete)
                    self.feedbackGenerator = nil

                    indicatorView.alpha = 1
                    let frame = indicatorView.frame
                    indicatorView.frame = CGRect(x: frame.origin.x, y: 0,
                                                 width: frame.size.width, height: frame.size.height)
                    UIView.animate(withDuration: AnimationDuration.duration2.value) {
                        indicatorView.frame = CGRect(
                            x: frame.origin.x,
                            y: -(frame.size.height + 8),
                            width: frame.size.width,
                            height: frame.size.height
                        )
                    }
                }
        }
    }

    /**
     Animate presented view controller dismissal
     */
    private func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {

        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from)
            else { return }

        // Calls viewWillAppear and viewWillDisappear
        toVC.beginAppearanceTransition(true, animated: true)

        let presentable = actionModalLayoutType(from: transitionContext)
        let actionView: UIView = transitionContext.containerView.mxActionContainerView ?? fromVC.view

        TymeXActionModalAnimator.cubicAnimateBy(
            presentable: presentable,
            transitionStyle: .dismissal) {
            actionView.frame.origin.y = transitionContext.containerView.frame.height
        } completion: { didComplete in
            fromVC.view.removeFromSuperview()
            // Calls viewDidAppear and viewDidDisappear
            toVC.endAppearanceTransition()
            transitionContext.completeTransition(didComplete)
        }
    }

    /**
     Extracts the ActionModal from the transition context, if it exists
     */
    private func actionModalLayoutType(
        from context: UIViewControllerContextTransitioning
    ) -> TymeXActionModalPresentable.TymeXLayoutType? {
        switch transitionStyle {
        case .presentation:
            return context.viewController(forKey: .to) as? TymeXActionModalPresentable.TymeXLayoutType
        case .dismissal:
            return context.viewController(forKey: .from) as? TymeXActionModalPresentable.TymeXLayoutType
        }
    }
}

// MARK: - UIViewControllerAnimatedTransitioning Delegate

extension TymeXActionModalPresentationAnimator: UIViewControllerAnimatedTransitioning {

    /**
     Returns the transition duration
     */
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {

        guard
            let context = transitionContext,
            let presentable = actionModalLayoutType(from: context)
        else { return TymeXActionModalAnimator.defaultTransitionDuration.value }
        switch transitionStyle {
        case .presentation:
            return presentable.presentMotionConfig.duration.value
        case .dismissal:
            return presentable.dismissalMotionConfig.duration.value
        }
    }

    /**
     Performs the appropriate animation based on the transition style
     */
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transitionStyle {
        case .presentation:
            animatePresentation(transitionContext: transitionContext)
        case .dismissal:
            animateDismissal(transitionContext: transitionContext)
        }
    }
}
