//
//  ActionModalPresentationController.swift
//  ios-ui-components
//
//  Created by Duy Le on 18/06/2021.
//

import UIKit
import Lottie

/**
 The ActionModalPresentationController is the middle layer between the presentingViewController
 and the presentedViewController.

 It controls the coordination between the individual transition classes as well as
 provides an abstraction over how the presented view is presented & displayed.

 For example, we add a drag indicator view above the presented view and
 a background overlay between the presenting & presented view.

 The presented view's layout configuration & presentation is defined using the ActionModalPresentable.

 By conforming to the ActionModalPresentable protocol & overriding values
 the presented view can define its layout configuration & presentation.
 */
open class TymeXActionModalPresentationController: UIPresentationController {

    /**
     Enum representing the possible presentation states
     */
    public enum PresentationState {
        case shortForm
        case longForm
        case loading
    }

    /**
     Constants
     */
    struct Constants {
        static let indicatorYOffset = CGFloat(8.0)
        static let snapMovementSensitivity = CGFloat(0.8)
        static let dragIndicatorSize = CGSize(width: 200, height: 48)
        static let indicatorTextMessage = "Swipe down to close"
    }

    // MARK: - Properties

    /**
     A flag to track if the presented view is animating
     */
    internal var isPresentedViewAnimating = false

    /**
     A flag to determine if scrolling should seamlessly transition
     from the action modal container view to the scroll view
     once the scroll limit has been reached.
     */
    internal var extendsActionScrolling = true

    /**
     A flag to determine if scrolling should be limited to the longFormHeight.
     Return false to cap scrolling at .max height.
     */
    internal var anchorModalToLongForm = true

    internal var presentationState: PresentationState = .shortForm

    /**
     The y content offset value of the embedded scroll view
     */
    internal var scrollViewYOffset: CGFloat = 0.0

    /**
     An observer for the scroll view content offset
     */
    internal var scrollObserver: NSKeyValueObservation?

    // store the y positions so we don't have to keep re-calculating

    /**
     The y value for the short form presentation state
     */
    internal var shortFormYPosition: CGFloat = 0

    /**
     The y value for the long form presentation state
     */
    internal var longFormYPosition: CGFloat = 0

    /**
     The y value for the loading form presentation state
     */
    internal var loadingFormYPosition: CGFloat = 0
    /**
     Determine anchored Y postion based on the `anchorModalToLongForm` flag
     */
    internal var anchoredYPosition: CGFloat {
        let defaultTopOffset = presentable?.mxTopOffset ?? 0
        return anchorModalToLongForm ? longFormYPosition : defaultTopOffset
    }

    /**
     Configuration object for ActionModalPresentationController
     */
    internal var presentable: TymeXActionModalPresentable? {
        return presentedViewController as? TymeXActionModalPresentable
    }

    // MARK: - Views

    /**
     Background view used as an overlay over the presenting view
     */
    internal lazy var backgroundView: TymeXDimmedView = {
        let view: TymeXDimmedView
        if let color = presentable?.mxActionModalBackgroundColor {
            view = TymeXDimmedView(dimColor: color)
        } else {
            view = TymeXDimmedView()
        }
        view.didTap = { [weak self] _ in
            if self?.presentable?.mxAllowsTapToDismiss == true {
                self?.presentedViewController.dismiss(animated: true)
            }
        }
        return view
    }()

    /**
     Loading view used as an overlay over the presenting view
     */
    internal lazy var loadingView: UIView = {
        let animationView = makeLoadingContentView()
        let animatedView = UIView()
        animatedView.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: animatedView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: animatedView.bottomAnchor),
            animationView.leftAnchor.constraint(equalTo: animatedView.leftAnchor),
            animationView.rightAnchor.constraint(equalTo: animatedView.rightAnchor)
        ])
        return animatedView
    }()

    private func makeLoadingContentView() -> UIView {
        let animationView = LottieAnimationView(
            animation: .named(
                SmokingCessation.loadingAnimation
            )
        )
        animationView.loopMode = .loop
        animationView.play(completion: nil)
        animationView.translatesAutoresizingMaskIntoConstraints = false

        return animationView
    }

    /**
     A wrapper around the presented view so that we can modify
     the presented view apperance without changing
     the presented view's properties
     */
    internal lazy var actionContainerView: TymeXActionContainerView = {
        let frame = containerView?.frame ?? .zero
        return TymeXActionContainerView(presentedView: presentedViewController.view, frame: frame)
    }()

    /**
     Drag Indicator View
     */
    lazy var defaultIndicatorView: UIView = {
        let label = UILabel(
            frame: CGRect(
                x: 0, y: 0,
                width: Constants.dragIndicatorSize.width,
                height: Constants.dragIndicatorSize.height
            )
        )
        label.attributedText = NSAttributedString(
            string: Constants.indicatorTextMessage,
            attributes: SmokingCessation.textLabelDefaultXs.color(SmokingCessation.colorIconInverse)
        )
        label.backgroundColor = UIColor.clear
        return label
    }()

    /**
     Override presented view to return the action container wrapper
     */
    public override var presentedView: UIView {
        return actionContainerView
    }

    // MARK: - Gesture Recognizers

    /**
     Gesture recognizer to detect & track pan gestures
     */
    internal lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPanOnPresentedView(_:)))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()

    // MARK: - Deinitializers

    deinit {
        scrollObserver?.invalidate()
    }

    // MARK: - Lifecycle

    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        configureViewLayout()
    }

    override public func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }

        // Need calculation if actionContainerView frame is zero
        if actionContainerView.frame == .zero {
            adjustPresentedViewFrame()
        }

        layoutBackgroundView(in: containerView)
        layoutPresentedView(in: containerView)
        configureScrollViewInsets()

        guard let coordinator = presentedViewController.transitionCoordinator else {
            backgroundView.dimState = .max
            return
        }

        let isQueuedSuccess = coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.backgroundView.dimState = .max
            self?.presentedViewController.setNeedsStatusBarAppearanceUpdate()
        })

        if !isQueuedSuccess {
            backgroundView.dimState = .max
        }
    }

    override public func presentationTransitionDidEnd(_ completed: Bool) {
        // make sure loadingView was shown only when the Modal has been presented already
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDuration.duration1.value) {
            self.loadingView.isHidden = false
        }
        if completed { return }
        backgroundView.removeFromSuperview()
    }

    override public func dismissalTransitionWillBegin() {
        NotificationCenter.default.post(name: Notification.Name("TymeXActionModalPresentationController"), object: nil)
        presentable?.mxActionModalWillDismiss()

        guard let coordinator = presentedViewController.transitionCoordinator else {
            backgroundView.dimState = .off
            return
        }

        /**
         Drag indicator is drawn outside of view bounds
         so hiding it on view dismiss means avoiding visual bugs
         */
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.defaultIndicatorView.alpha = 0.0
            self?.backgroundView.dimState = .off
            self?.presentingViewController.setNeedsStatusBarAppearanceUpdate()
        })
    }

    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        if !completed { return }

        presentable?.mxActionModalDidDismiss()
    }

    /**
     Update presented view size in response to size class changes
     */
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard
                let self = self,
                let presentable = self.presentable
            else { return }

            self.adjustPresentedViewFrame()
            if presentable.mxShouldRoundTopCorners {
                self.addRoundedCorners(to: self.presentedView)
            }
        })
    }

    /**
     Get Indicator View
     */
    func getIndicatorView() -> UIView {
        return presentable?.mxCustomDragIndicatorView ?? defaultIndicatorView
    }
}
