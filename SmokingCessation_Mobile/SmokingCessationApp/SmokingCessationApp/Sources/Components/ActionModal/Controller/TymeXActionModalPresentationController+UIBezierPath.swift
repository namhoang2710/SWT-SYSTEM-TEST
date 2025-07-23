//
//  ActionModalPresentationController+UIBezierPath.swift
//  TymeComponent
//
//  Created by Duy Le on 25/06/2021.
//

import UIKit

// MARK: - UIBezierPath

internal extension TymeXActionModalPresentationController {

    /**
     Draws top rounded corners on a given view
     We have to set a custom path for corner rounding
     because we render the dragIndicator outside of view bounds
     */
    func addRoundedCorners(to view: UIView) {
        let radius = presentable?.mxCornerRadius ?? 0
        let path = UIBezierPath(
            roundedRect: view.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        view.backgroundColor = .red
        // Draw around the drag indicator view, if displayed
        if presentable?.mxShowDragIndicator == true {
            let indicatorView = getIndicatorView()
            let width = indicatorView.frame.width
            let indicatorLeftEdgeXPos = view.bounds.width/2.0 - width/2.0
            drawAroundDragIndicator(currentPath: path, indicatorLeftEdgeXPos: indicatorLeftEdgeXPos)
        }

        // Set path as a mask to display optional drag indicator view & rounded corners
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask

        // Improve performance by rasterizing the layer
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }

    /**
     Draws a path around the drag indicator view
     */
    func drawAroundDragIndicator(currentPath path: UIBezierPath, indicatorLeftEdgeXPos: CGFloat) {
        let indicatorView = getIndicatorView()
        let height = indicatorView.frame.height
        let totalIndicatorOffset = Constants.indicatorYOffset + height

        // Draw around drag indicator starting from the left
        path.addLine(to: CGPoint(x: indicatorLeftEdgeXPos, y: path.currentPoint.y))
        path.addLine(to: CGPoint(x: path.currentPoint.x, y: path.currentPoint.y - totalIndicatorOffset))
        let width = indicatorView.frame.width
        path.addLine(to: CGPoint(x: path.currentPoint.x + width, y: path.currentPoint.y))
        path.addLine(to: CGPoint(x: path.currentPoint.x, y: path.currentPoint.y + totalIndicatorOffset))
    }
}
