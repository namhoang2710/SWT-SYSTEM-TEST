//
//  UIPanGestureRecognizerExtensions.swift
//  TymeComponent
//
//  Created by Tuan Pham on 20/04/2022.
//

import UIKit

extension UIPanGestureRecognizer {

   public enum TymeXGestureDirection {
        // swiftlint:disable identifier_name
        case up
        case down
        case left
        case right
       // swiftlint:enable identifier_name
    }

    /// Get current vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    public func mxVerticalDirection(target: UIView) -> TymeXGestureDirection {
        return self.velocity(in: target).y > 0 ? .down : .up
    }

    /// Get current horizontal direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func mxHorizontalDirection(target: UIView) -> TymeXGestureDirection {
        return self.velocity(in: target).x > 0 ? .right : .left
    }

    /// Get a tuple for current horizontal/vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func mxVersus(target: UIView) -> (horizontal: TymeXGestureDirection, vertical: TymeXGestureDirection) {
        return (self.mxHorizontalDirection(target: target), self.mxVerticalDirection(target: target))
    }

}
