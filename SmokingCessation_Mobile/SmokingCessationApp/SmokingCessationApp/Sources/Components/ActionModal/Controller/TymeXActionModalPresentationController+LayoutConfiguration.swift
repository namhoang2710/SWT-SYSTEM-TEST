//
//  ActionModalPresentationController+LayoutConfiguration.swift
//  TymeComponent
//
//  Created by Duy Le on 25/06/2021.
//

import UIKit

// MARK: - Presented View Layout Configuration

internal extension TymeXActionModalPresentationController {

    /**
     Boolean flag to determine if the presented view is anchored
     */
    var isPresentedViewAnchored: Bool {
        if !isPresentedViewAnimating
            && extendsActionScrolling
            && presentedView.frame.minY.rounded() <= anchoredYPosition.rounded() {
            return true
        }

        return false
    }

    /**
     Adds the presented view to the given container view
     & configures the view elements such as drag indicator, rounded corners
     based on the action modal presentable.
     */
    func layoutPresentedView(in containerView: UIView) {

        /**
         If the presented view controller does not conform to action modal presentable
         don't configure
         */
        guard let presentable = presentable
            else { return }

        /**
         ⚠️ If this class is NOT used in conjunction with the ActionModalPresentationAnimator
         & ActionModalPresentable, the presented view should be added to the container view
         in the presentation animator instead of here
         */
        containerView.addSubview(presentedView)
        containerView.addGestureRecognizer(panGestureRecognizer)

        if presentable.mxShowDragIndicator {
            addDragIndicatorView(to: presentedView)
        }

        if presentable.mxShouldRoundTopCorners {
            addRoundedCorners(to: presentedView)
        }

        setNeedsLayoutUpdate()
        adjustActionContainerBackgroundColor()
    }

    /**
     Reduce height of presentedView so that it sits at the bottom of the screen
     */
    func adjustPresentedViewFrame() {
        guard let frame = containerView?.frame
            else { return }

        let adjustedSize = CGSize(width: frame.size.width, height: frame.size.height - anchoredYPosition)
        let actionFrame = actionContainerView.frame
        actionContainerView.frame.size = frame.size

        if ![shortFormYPosition, longFormYPosition, loadingFormYPosition].contains(actionFrame.origin.y) {
            // if the container is already in the correct position, no need to adjust positioning
            // (rotations & size changes cause positioning to be out of sync)
            let yPosition = actionFrame.origin.y - actionFrame.height + frame.height
            if presentationState == .loading {
                presentedView.frame.origin.y = max(loadingFormYPosition, anchoredYPosition)
            } else {
                presentedView.frame.origin.y = max(yPosition, anchoredYPosition)
            }
        }
        actionContainerView.frame.origin.x = frame.origin.x
        presentedViewController.view.frame = CGRect(origin: .zero, size: adjustedSize)
    }

    /**
     Reduce frame & re-caculate YPOS
     */
    func adjustPresentedViewFrameResetYPos() {
        guard let frame = containerView?.frame
            else { return }

        let adjustedSize = CGSize(width: frame.size.width, height: frame.size.height - anchoredYPosition)
        actionContainerView.frame.size = frame.size
        var yPosition = longFormYPosition
        if presentationState == .loading {
            yPosition = loadingFormYPosition
        } else if presentationState == .shortForm {
            yPosition = shortFormYPosition
        }
        if presentationState == .loading {
            presentedView.frame.origin.y = max(loadingFormYPosition, anchoredYPosition)
        } else {
            presentedView.frame.origin.y = max(yPosition, anchoredYPosition)
        }
        actionContainerView.frame.origin.x = frame.origin.x
        presentedViewController.view.frame = CGRect(origin: .zero, size: adjustedSize)
    }

    /**
     Adds a background color to the action container view
     in order to avoid a gap at the bottom
     during initial view presentation in longForm (when view bounces)
     */
    func adjustActionContainerBackgroundColor() {
        actionContainerView.backgroundColor = presentedViewController.view.backgroundColor
            ?? presentable?.actionScrollable?.backgroundColor
    }

    /**
     Adds the background view to the view hierarchy
     & configures its layout constraints.
     */
    func layoutBackgroundView(in containerView: UIView) {
        containerView.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }

    /**
     Adds the drag indicator view to the view hierarchy
     & configures its layout constraints.
     */
    func addDragIndicatorView(to view: UIView) {
        let indicatorView = getIndicatorView()
        view.addSubview(indicatorView)
        view.sendSubviewToBack(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.bottomAnchor.constraint(
            equalTo: view.topAnchor,
            constant: -Constants.indicatorYOffset
        ).isActive = true
        indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    /**
     Adds the loading indicator view to the view hierarchy
     & configures its layout constraints.
     */
    private func addLoadingView(to view: UIView) {
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView.heightAnchor.constraint(equalToConstant: 24),
            loadingView.widthAnchor.constraint(equalToConstant: 24),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        loadingView.isHidden = true
    }

    private func removeLoadingView() {
        loadingView.removeFromSuperview()
    }

    /**
     Calculates & stores the layout anchor points & options
     */
    func configureViewLayout() {

        guard let layoutPresentable = presentedViewController as? TymeXActionModalPresentable.TymeXLayoutType
            else { return }

        shortFormYPosition = layoutPresentable.shortFormYPos
        longFormYPosition = layoutPresentable.longFormYPos
        loadingFormYPosition = layoutPresentable.loadingFormYPos
        anchorModalToLongForm = layoutPresentable.mxAnchorModalToLongForm
        extendsActionScrolling = layoutPresentable.mxAllowsExtendedActionScrolling

        containerView?.isUserInteractionEnabled = layoutPresentable.mxIsUserInteractionEnabled
    }

    /**
     Showing loading in state loading
     */
    func configLoadingView() {
        if presentationState == .loading {
            addLoadingView(to: self.presentedView)
        } else {
            removeLoadingView()
        }
    }

    /**
     Configures the scroll view insets
     */
    func configureScrollViewInsets() {

        guard
            let scrollView = presentable?.actionScrollable,
            !scrollView.mxIsScrolling
            else { return }

        /**
         Disable vertical scroll indicator until we start to scroll
         to avoid visual bugs
         */
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollIndicatorInsets = presentable?.mxScrollIndicatorInsets ?? .zero

        /**
         Set the appropriate contentInset as the configuration within this class
         offsets it
         */
        scrollView.contentInset.bottom = presentingViewController.bottomLayoutGuide.length

        /**
         As we adjust the bounds during `handleScrollViewTopBounce`
         we should assume that contentInsetAdjustmentBehavior will not be correct
         */
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
}
