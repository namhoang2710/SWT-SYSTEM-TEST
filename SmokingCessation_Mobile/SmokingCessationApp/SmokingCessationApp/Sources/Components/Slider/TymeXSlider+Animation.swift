//
//  TymeXSlider+Animation.swift
//  TymeXUIComponent
//
//  Created by Duy Huynh on 17/4/25.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXSlider {
    // MARK: - Indicator Label Animations
    /// Show the indicator badge with an animation.
    func showIndicator() {
        guard showsIndicator else {
            print("showsIndicator is false; not displaying indicator.")
            return
        }
        // Indicator is behind the thumb.
        trackContainer.insertSubview(indicatorLabel, belowSubview: thumbImageView)

        indicatorLabel.attributedText = generateBadgeAttributedString()
        indicatorLabel.sizeToFit()
        // Indicator positioned at the thumb center and scaled to zero initially.
        indicatorLabel.center = thumbImageView.center
        indicatorLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
        indicatorLabel.isHidden = false

        let finalCenterX = thumbImageView.center.x
        let finalCenterY = thumbImageView.frame.minY - indicatorLabel.bounds.height / 2 - indicatorVerticalOffset
        let finalCenter = CGPoint(x: finalCenterX, y: finalCenterY)
        /// animation
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            self.indicatorLabel.center = finalCenter
            self.indicatorLabel.transform = .identity
        })
    }

    /// Update the indicator badge as the thumb moves.
    func updateIndicator() {
        guard showsIndicator else { return }
        trackContainer.insertSubview(indicatorLabel, belowSubview: thumbImageView)
        // refresh text & size
        indicatorLabel.attributedText = generateBadgeAttributedString()
        indicatorLabel.sizeToFit()
        // exactly at the thumb’s center
        let idealX = thumbImageView.center.x
        let halfBadge = indicatorLabel.bounds.width / 2
        let halfThumb = thumbImageView.bounds.width / 2
        let minX = halfBadge - (halfThumb / 2)
        let maxX = bounds.width - halfBadge + (halfThumb / 2)
        // clamp
        let centerX = min(max(idealX, minX), maxX)
        let centerY = thumbImageView.frame.minY - indicatorLabel.bounds.height / 2 - indicatorVerticalOffset
        indicatorLabel.center = CGPoint(x: centerX, y: centerY)
    }

    /// Hide the indicator badge with an animation.
    func hideIndicator() {
        /// animation
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            self.indicatorLabel.center = self.thumbImageView.center
            self.indicatorLabel.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }, completion: { _ in
            self.indicatorLabel.isHidden = true
            self.indicatorLabel.transform = .identity
        })
    }
}
