//
//  TymeXListViewV2+Gestures.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 03/01/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIGestureRecognizerDelegate
extension TymeXListViewV2 {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // If the gesture is from the cell's swipe gesture
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }

        let velocity = panGesture.velocity(in: gestureRecognizer.view)
        // If the gesture is horizontal (swipe), don't allow simultaneous recognition
        if abs(velocity.x) > abs(velocity.y) {
            return false
        }

        // For all other cases, allow simultaneous recognition
        return true
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // If the gesture is from the cell's swipe gesture
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }

        // If the gesture is horizontal (swipe), don't require it to fail
        let isSwipeHorizontal = isSwipeHorizontal(gestureRecognizer: panGesture)
        if isSwipeHorizontal {
            return false
        }

        // For all other cases, don't require the gesture to fail
        return false
    }

    func handleSwiftLeftGesture(translationX: Double, for cell: TymeXListStandardCell) {
        let halfCellWidth = cell.contentView.bounds.width / 2
        let threadholdSwipeWidth = halfCellWidth * 0.6

        // Transform position
        updateCellTransform(for: cell, with: translationX, halfCellWidth: halfCellWidth)

        // Play lottie with new progress
        let newProgress = calculateSwipeProgress(
            translationX: translationX, threadholdSwipeWidth: threadholdSwipeWidth
        )
        updateLottieAnimationProgress(for: cell, newProgress: newProgress)

        // Update title
        let isFavorite = cell.model?.trailingStatus?.isFavorite() ?? false
        cell.swipeActionView.updateTitle(title: isFavorite ? "Unfavorite" : "Favorite")
    }

    func handleEndGesture(translationX: Double, for cell: TymeXListStandardCell) {
        let halfCellWidth = cell.contentView.bounds.width / 2
        let threadholdSwipeWidth = halfCellWidth * 0.6
        let threadHoldRatio = 0.91
        let isFavorite = cell.model?.trailingStatus?.isFavorite() ?? false
        let swipeActionState = isFavorite ? TymeXSwipeActionState.unfavoriteBurst : TymeXSwipeActionState.favoriteBurst

        let newProgress = calculateSwipeProgress(
            translationX: translationX, threadholdSwipeWidth: threadholdSwipeWidth
        )

        if newProgress >= threadHoldRatio {
            // In case swipe action > threadHoldRatio then trigger action Success
            playSwipeAction(for: cell, swipeActionState: swipeActionState)
        } else {
            // Reset position
            resetCellPosition(for: cell, completion: nil)
        }
    }

    public func isSwipeHorizontal(gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
        if abs(velocity.x) > abs(velocity.y) {
            return true
        }
        return false
    }
}
