//
//  ActionCardSheetContainer+UIScrollView.swift
//  TymeComponent
//
//  Created by Tuan Pham on 21/04/2022.
//

import UIKit

extension TymeXActionCardSheetContainerController {

    func shouldRespond(to panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        guard presentable.mxShouldRespond(to: panGestureRecognizer) ||
                !(panGestureRecognizer.state == .began || panGestureRecognizer.state == .cancelled)
        else {
            panGestureRecognizer.isEnabled = false
            panGestureRecognizer.isEnabled = true
            return false
        }

        return !shouldFail(panGestureRecognizer: panGestureRecognizer)
    }

    func shouldFail(panGestureRecognizer: UIPanGestureRecognizer) -> Bool {

        guard !shouldPrioritize(panGestureRecognizer: panGestureRecognizer) else {
            presentable.actionScrollable?.panGestureRecognizer.isEnabled = false
            presentable.actionScrollable?.panGestureRecognizer.isEnabled = true
            return false
        }

        let direction = panGestureRecognizer.mxVerticalDirection(target: view)
        guard let scrollView = presentable.actionScrollable,
            scrollView.contentOffset.y > 0,
              direction == .down
            else {
                return false
        }

        let loc = panGestureRecognizer.location(in: view)
        return scrollView.bounds.contains(loc) || scrollView.mxIsScrolling
    }

    func shouldPrioritize(panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return panGestureRecognizer.state == .began &&
            presentable.mxShouldPrioritize(panModalGestureRecognizer: panGestureRecognizer)
    }
}

extension TymeXActionCardSheetContainerController: UIGestureRecognizerDelegate {

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
        return otherGestureRecognizer.view == presentable.actionScrollable
    }
}
