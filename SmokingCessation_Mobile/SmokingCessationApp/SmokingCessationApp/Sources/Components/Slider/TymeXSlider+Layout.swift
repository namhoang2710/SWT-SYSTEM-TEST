//
//  TymeXSlider+Layout.swift
//  TymeXUIComponent
//
//  Created by Duy Huynh on 17/4/25.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension TymeXSlider {
    // MARK: - Layout
    func setupMainStack() {
        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
          mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
          mainStack.topAnchor.constraint(equalTo: topAnchor),
          mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        trackContainer.translatesAutoresizingMaskIntoConstraints = false
        let thumbH = thumbImageView.intrinsicContentSize.height
        trackContainer.heightAnchor
          .constraint(equalToConstant: thumbH)
          .isActive = true

        trackContainer.setContentHuggingPriority(.required, for: .vertical)
        labelsStack.setContentHuggingPriority(.defaultLow, for: .vertical)

        minLabel.numberOfLines = 2
        minLabel.lineBreakMode = .byTruncatingTail
        maxLabel.numberOfLines = 2
        maxLabel.lineBreakMode = .byTruncatingTail
        maxLabel.textAlignment = .right
        minLabel.textAlignment = .left
        mainStack.isUserInteractionEnabled    = false
        trackContainer.isUserInteractionEnabled = false
        labelsStack.isUserInteractionEnabled  = false
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        setupMinMaxLabels()
        layoutIfNeeded()
        let trackH: CGFloat = ConstantsSlider.trackHeight
        let area = trackContainer.bounds
        let trackY = (area.height - trackH) / 2
        trackLayer.frame = CGRect(
            x: 0,
            y: trackY,
            width: area.width,
            height: trackH)

        trackLayer.cornerRadius = getCornerRadiusBase(forHeight: trackH)
        updateFillLayer(in: area)
        updateThumbPosition(in: area)
        updateIndicatorDots(in: area)
    }

    open override func didMoveToSuperview() {
      super.didMoveToSuperview()
      setNeedsLayout()
      layoutIfNeeded()
    }

    // MARK: - Update Methods
    /// Computes a discrete ratio based on the current indicator value by snapping to the nearest step.
        private func discreteRatio() -> CGFloat {
            guard numberOfSteps > 1 else { return 0 }
            let segments = numberOfSteps - 1
            let range     = maximumValue - minimumValue
            let stepSize  = range / Decimal(segments)
            let offset    = indicatorValue - minimumValue
            let rawIndex  = offset / stepSize
            let snapped   = rawIndex.rounded(scale: 0)
            let index     = NSDecimalNumber(decimal: snapped)
                          .intValue
            return CGFloat(index) / CGFloat(segments)
        }

       private func calculateRatio() -> CGFloat {
           if numberOfSteps > 1 {
               return discreteRatio()
           }
           let range = maximumValue - minimumValue
           guard range != 0 else { return 0 }
           let ratioDecimal = (indicatorValue - minimumValue) / range
           return CGFloat(truncating: ratioDecimal as NSNumber)
    }

    private func calculateEffectiveWidth(leftInset: CGFloat, area: CGRect) -> CGFloat {
        area.width - 2 * leftInset
       }

     func updateFillLayer(in area: CGRect) {
            let ratio = calculateRatio()
            let fillW = area.width * ratio
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            fillLayer.frame = CGRect(
                x: 0,
                y: (area.height - ConstantsSlider.trackHeight)/2,
                width: fillW,
                height: ConstantsSlider.trackHeight
            )
            fillLayer.cornerRadius = getCornerRadiusBase(forHeight: ConstantsSlider.trackHeight)
            CATransaction.commit()
        }

    func updateThumbPosition(in area: CGRect) {
           let leftInset: CGFloat = SmokingCessation.spacing2
           let effectiveWidth = calculateEffectiveWidth(leftInset: leftInset, area: area)
           let ratio = calculateRatio()
           let thumbCenterX = leftInset + effectiveWidth * ratio
           let thumbSize = thumbImageView.intrinsicContentSize
           let xPoint = thumbCenterX - thumbSize.width / 2
        let yPoint = area.height / 2 - thumbSize.height / 2
           thumbImageView.frame = CGRect(origin: CGPoint(x: xPoint, y: yPoint), size: thumbSize)
       }

    private func updateIndicatorDots(in area: CGRect) {
            indicatorDots.forEach { $0.removeFromSuperlayer() }
            indicatorDots.removeAll()
            guard numberOfSteps > 1 else { return }
            let totalDots = numberOfSteps
            let leftInset: CGFloat = SmokingCessation.spacing2
            let effectiveWidth = area.width - 2 * leftInset
            let trackCenterY = area.height / 2
            let dotSize: CGFloat = 4
            for step in 0..<totalDots {
                let ratio = CGFloat(step) / CGFloat(totalDots - 1)
                let centerX = leftInset + effectiveWidth * ratio
                let frame = CGRect(
                    x: centerX - dotSize / 2,
                    y: trackCenterY - dotSize / 2,
                    width: dotSize,
                    height: dotSize)
                let dot = CALayer()
                dot.frame = frame
                dot.backgroundColor = UIColor.white.cgColor
                dot.cornerRadius = dotSize / 2
                dot.name = "indicatorDotTymeXSlider_\(step + 1)"
                trackContainer.layer.insertSublayer(dot, below: thumbImageView.layer)
                indicatorDots.append(dot)
            }
            afterDotsUpdate?(indicatorDots)
        }

    // MARK: - Badge Attachment Helper
    public func generateBadgeAttributedString() -> NSAttributedString {
            let text: String
            switch valueType {
            case .integer:
                // exact integer
                let intVal = NSDecimalNumber(decimal: indicatorValue).intValue
                text = "\(intVal)"
            case .decimal(let places):
                if let places = places {
                    let formatter = NumberFormatter()
                    formatter.usesGroupingSeparator = false
                    formatter.minimumFractionDigits = places
                    formatter.maximumFractionDigits = places
                    formatter.numberStyle = .decimal
                    text = formatter.string(from: indicatorValue as NSNumber) ?? "\(indicatorValue)"
                } else { text = indicatorValue.formatAmount() }
            }

            let badge = TymeXSelectionCardBadgeText(
                text: text,
                textAttributes: SmokingCessation.textLabelEmphasizeM.color(SmokingCessation.colorTextInverse),
                backgroundColor: SmokingCessation.colorBackgroundSecondaryBase,
                cornerRadius: getCornerRadiusBase(),
                padding: .init(top: SmokingCessation.spacing2,
                               left: SmokingCessation.spacing3,
                               bottom: SmokingCessation.spacing2,
                               right: SmokingCessation.spacing3)
            )
            return NSAttributedString(attachment: badge)
        }
}
