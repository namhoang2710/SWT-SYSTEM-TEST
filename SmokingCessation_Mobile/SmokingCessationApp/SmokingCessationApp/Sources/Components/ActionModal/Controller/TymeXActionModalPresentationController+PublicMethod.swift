//
//  ActionModalPresentationController+PublicMethod.swift
//  TymeComponent
//
//  Created by Duy Le on 25/06/2021.
//

import UIKit

// MARK: - Public Methods

public extension TymeXActionModalPresentationController {

    /**
     Transition the ActionModalPresentationController
     to the given presentation state
     */
    func transition(to state: PresentationState) {

        guard presentable?.mxShouldTransition(to: state) == true
            else { return }

        presentable?.mxWillTransition(to: state)
        presentationState = state
        switch state {
        case .shortForm:
            snap(toYPosition: shortFormYPosition)
        case .longForm:
            snap(toYPosition: longFormYPosition)
        case .loading:
            snap(toYPosition: loadingFormYPosition)
        }
    }

    /**
     Operations on the scroll view, such as content height changes,
     or when inserting/deleting rows can cause the action modal to jump,
     caused by the action modal responding to content offset changes.

     To avoid this, you can call this method to perform scroll view updates,
     with scroll observation temporarily disabled.
     */
    func performUpdates(_ updates: () -> Void) {

        guard let scrollView = presentable?.actionScrollable
            else { return }

        // Pause scroll observer
        scrollObserver?.invalidate()
        scrollObserver = nil

        // Perform updates
        updates()

        // Resume scroll observer
        trackScrolling(scrollView)
        observe(scrollView: scrollView)
    }

    /**
     Updates the ActionModalPresentationController layout
     based on values in the ActionModalPresentable

     - Note: This should be called whenever any
     action modal presentable value changes after the initial presentation
     */
    func setNeedsLayoutUpdate() {
        configureViewLayout()
        adjustPresentedViewFrame()
        observe(scrollView: presentable?.actionScrollable)
        configureScrollViewInsets()
        configLoadingView()
    }

    func setNeedsLayoutUpdateResetYPos(state: PresentationState) {
        presentationState = state
        switch state {
        case .shortForm:
            snap(toYPosition: shortFormYPosition)
        case .longForm:
            snap(toYPosition: longFormYPosition)
        case .loading:
            snap(toYPosition: loadingFormYPosition)
        }
        configureViewLayout()
        adjustPresentedViewFrameResetYPos()
        observe(scrollView: presentable?.actionScrollable)
        configureScrollViewInsets()
        configLoadingView()
    }
}
