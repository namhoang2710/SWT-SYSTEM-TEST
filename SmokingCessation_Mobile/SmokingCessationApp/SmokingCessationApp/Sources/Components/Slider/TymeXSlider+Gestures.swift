//
//  TymeXSlider+Gestures.swift
//  TymeXUIComponent
//
//  Created by Duy Huynh on 17/4/25.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXSlider {
    // MARK: - Touch Handling
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: trackContainer)
        print("beginTracking at: \(location)")
        // If they touched the thumb, show the indicator (after your long‑press)
        if thumbImageView.frame.contains(location) {
            guard showsIndicator && indicatorLabel.isHidden else {
                    TymeXHapticFeedback.medium.vibrate()
                return true
            }
                print("Manual long press detected.")
                TymeXHapticFeedback.medium.vibrate()
                showIndicator()
                updateIndicator()
        } else {
            TymeXHapticFeedback.light.vibrate()
            updateValue(for: location.x)
        }
        return true
    }

    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: trackContainer)
        print("continueTracking at: \(location)")
        updateValue(for: location.x)

        if !indicatorLabel.isHidden && showsIndicator {
            updateIndicator()
        } else {
            showIndicator()
            updateIndicator()
        }

        return true
    }

    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        print("endTracking")
        super.endTracking(touch, with: event)
        if !indicatorLabel.isHidden && showsIndicator {
            hideIndicator()
        }
    }

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let pointInTrack = convert(point, to: trackContainer)
        if trackContainer.bounds.contains(pointInTrack) {
            return true
        }
        let pointInThumb = convert(point, to: thumbImageView)
        if thumbImageView.bounds.contains(pointInThumb) {
            return true
        }
        return false
    }

    // MARK: - Touch Handling
    /// Update slider value based on the given x-coordinate.
    private func updateValue(for locationX: CGFloat) {
        // where along the track they touched
        let clampedX = max(0, min(locationX, bounds.width))
        let ratio    = clampedX / bounds.width
        var newValue = Decimal(ratio) * (maximumValue - minimumValue) + minimumValue

        if numberOfSteps > 1 {
            // --- DISCRETE MODE ---
            let segments = numberOfSteps - 1
            let stepSize = (maximumValue - minimumValue) / Decimal(segments)
            let offset   = newValue - minimumValue
            let snapped  = (offset / stepSize).rounded() * stepSize
            newValue     = minimumValue + snapped
            if case .integer = valueType {
                newValue = newValue.rounded()
            }

        } else {
            // --- CONTINUOUS MODE ---
            if let roundFunc = valueRounding {
                newValue = roundFunc(newValue)
            } else {
                switch valueType {
                case .integer:
                    newValue = newValue.rounded()
                case .decimal:
                    break
                }
            }
        }

        if newValue != indicatorValue {
            indicatorValue = newValue
        }
    }
}
