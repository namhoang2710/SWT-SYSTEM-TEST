//
//  TymeXListViewV2+Animation.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 30/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit
import Lottie

extension TymeXListViewV2 {
    func playHintAnimation(cell: TymeXListStandardCell) {
        guard let model = cell.model else { return }
        // stop play hint if swipe action was performed by user
        if !isFirstSwipeCell && model.isAllowToPlayHintAnimation {
            // Run animation to move cell's position
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: { [weak self] in
                // Move cell's position to left 50 px
                cell.transform = CGAffineTransform(translationX: -50, y: 0)

                // update right padding for lineView
                cell.updateLineViewConstraints(newTrailingConstant: SmokingCessation.spacing10)
                self?.playSpringAnimation(cell: cell)
            })
        }
    }

    private func playSpringAnimation(cell: TymeXListStandardCell) {
        UIView.animate(
            withDuration: 0.8,
            delay: 0.35,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1.0,
            options: [],
            animations: {
                cell.transform = .identity
            },
            completion: { _ in
                // Reset right padding for lineView
                cell.updateLineViewConstraints(newTrailingConstant: -SmokingCessation.spacing4)

                // Delay 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    // re-trigger play hint animation
                    self.playHintAnimation(cell: cell)
                }
            }
        )
    }

    func updateLottieAnimationProgress(for cell: TymeXListStandardCell, newProgress: CGFloat) {
        let currentProgress = cell.swipeActionView.lottieAnimationView.currentProgress
        cell.swipeActionView.playLottieFromCurrentProgress(currentProgress, toProgress: newProgress)
    }

    func playSwipeAction(for cell: TymeXListStandardCell, swipeActionState: TymeXSwipeActionState) {
        cell.swipeActionView.playLottie(for: swipeActionState) { isCompleted in
            if isCompleted {
                self.resetCellPosition(for: cell, completion: {
                    self.updateFavorite(for: cell)
                })
            }
        }
    }
}
