//
//  TymeXListBaseCell.swift
//  TymeXUIComponent
//
//  Created by Tung Nguyen on 20/2/25.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public class TymeXListBaseCell: UITableViewCell {
    var cellPosition: TymeXListCellPosition = .none
    var cachedBounds: CGRect?
    var isShowSectionBorderNeeded: Bool = false
    func setPosition(position: TymeXListCellPosition, isShowSectionBorderNeeded: Bool = false) {
        self.cellPosition = position
        self.isShowSectionBorderNeeded = isShowSectionBorderNeeded
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard cachedBounds != bounds, isShowSectionBorderNeeded else {
            return
        }
        self.cachedBounds = bounds
        setupView(
            radius: SmokingCessation.cornerRadius3,
            borderWidth: 1,
            borderColor: SmokingCessation.colorDividerDividerBase,
            position: cellPosition)
    }

    var borderLayer: CAShapeLayer?

    func setupView(
        radius: CGFloat,
        borderWidth: CGFloat,
        borderColor: UIColor,
        position: TymeXListCellPosition
    ) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        // Remove existing border layer
        borderLayer?.removeFromSuperlayer()

        // Create and configure new border layer
        let newBorderLayer = createBorderLayer(borderWidth: borderWidth, borderColor: borderColor)
        let adjustedBounds = bounds.insetBy(dx: borderWidth, dy: 0)
        let path = createPath(for: position, in: adjustedBounds, with: radius)

        // Configure view's layer
        configureViewLayer(radius: radius, maskedCorners: maskedCorners(for: position))

        // Set path and add new border layer
        newBorderLayer.path = path.cgPath
        layer.addSublayer(newBorderLayer)

        // Finalize transaction
        CATransaction.commit()

        // Update border layer reference
        borderLayer = newBorderLayer
        borderLayer?.superlayer?.masksToBounds = false
    }

    private func createBorderLayer(borderWidth: CGFloat, borderColor: UIColor) -> CAShapeLayer {
        let newBorderLayer = CAShapeLayer()
        newBorderLayer.strokeColor = borderColor.cgColor
        newBorderLayer.lineWidth = borderWidth
        newBorderLayer.fillColor = UIColor.clear.cgColor
        newBorderLayer.shouldRasterize = false
        newBorderLayer.zPosition = 0
        return newBorderLayer
    }

    private func createPath(
        for position: TymeXListCellPosition,
        in bounds: CGRect, with radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        switch position {
        case .single:
            path.append(UIBezierPath(roundedRect: bounds, cornerRadius: radius))
        case .first:
            path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + radius))
            path.addArc(withCenter: CGPoint(x: bounds.minX + radius, y: bounds.minY + radius),
                        radius: radius, startAngle: .pi, endAngle: -.pi/2, clockwise: true)
            path.addLine(to: CGPoint(x: bounds.maxX - radius, y: bounds.minY))
            path.addArc(withCenter: CGPoint(x: bounds.maxX - radius, y: bounds.minY + radius),
                        radius: radius, startAngle: -.pi/2, endAngle: 0, clockwise: true)
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        case .last:
            path.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - radius))
            path.addArc(withCenter: CGPoint(x: bounds.maxX - radius, y: bounds.maxY - radius),
                        radius: radius, startAngle: 0, endAngle: .pi/2, clockwise: true)
            path.addLine(to: CGPoint(x: bounds.minX + radius, y: bounds.maxY))
            path.addArc(withCenter: CGPoint(x: bounds.minX + radius, y: bounds.maxY - radius),
                        radius: radius, startAngle: .pi/2, endAngle: .pi, clockwise: true)
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
        case .middle:
            path.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            path.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        case .none:
            break
        }
        return path
    }

    private func maskedCorners(for position: TymeXListCellPosition) -> CACornerMask {
        switch position {
        case .single:
            return [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .first:
            return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .last:
            return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .middle, .none:
            return []
        }
    }

    private func configureViewLayer(radius: CGFloat, maskedCorners: CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = maskedCorners
    }
}
