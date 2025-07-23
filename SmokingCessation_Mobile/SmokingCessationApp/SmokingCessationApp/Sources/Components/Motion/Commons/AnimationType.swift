//
//  AnimationType.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import Foundation

public enum AnimationType {
    case slide(way: Way, direction: Direction)
    case squeeze(way: Way, direction: Direction)
    case slideFade(way: Way, direction: Direction)
    case squeezeFade(way: Way, direction: Direction)
    case fade(way: FadeWay)
    case zoom(way: Way)
    case zoomInvert(way: Way)
    case shake(repeatCount: Int)
    case pop(repeatCount: Int)
    case squash(repeatCount: Int)
    case flip(along: Axis)
    case morph(repeatCount: Int)
    case flash(repeatCount: Int)
    case wobble(repeatCount: Int)
    case swing(repeatCount: Int)
    case rotate(direction: RotationDirection, repeatCount: Int)
    case moveBy(xValue: Double, yValue: Double)
    case scale(fromX: Double, fromY: Double, toX: Double, toY: Double)
    case spin(repeatCount: Int)
    case compound(animations: [AnimationType], run: Run)
    case none

    // swiftlint:disable identifier_name
    public enum FadeWay: String {
        case `in`, out, inOut = "inout", outIn = "outin"
    }
    public enum Way: String {
        case out, `in`
    }
    public enum Axis: String {
        case x, y
    }
    public enum Direction: String {
        case left, right, up, down

        func isVertical() -> Bool {
            return self == .down || self == .up
        }
    }
    public enum RotationDirection: String {
        case cw, ccw
    }
    public enum Run: String {
        case sequential, parallel
    }
    // swiftlint:enable identifier_name
}

extension AnimationType.Axis: CaseIterable {}
extension AnimationType.Direction: CaseIterable {}
extension AnimationType.FadeWay: CaseIterable {}
extension AnimationType.RotationDirection: CaseIterable {}
extension AnimationType.Run: CaseIterable {}
extension AnimationType.Way: CaseIterable {}

extension AnimationType {
    public static func scaleTo(
        xValue: Double,
        yValue: Double
    ) -> AnimationType {
        return .scale(fromX: 1, fromY: 1, toX: xValue, toY: yValue)
    }
    public static func scaleFrom(
        xValue: Double,
        yValue: Double
    ) -> AnimationType {
        return .scale(fromX: xValue, fromY: yValue, toX: 1, toY: 1)
    }
}

extension AnimationType {
    public static func + (lhs: inout AnimationType, rhs: AnimationType) -> AnimationType {
        switch (lhs, rhs) {
        case (.compound(let lanimation, .parallel), .compound(let ranimation, .parallel)):
            return .compound(animations: lanimation + ranimation, run: .parallel)
        case (.compound(let lanimation, .parallel), _):
            var animation = lanimation
            animation.append(rhs)
            return .compound(animations: animation, run: .parallel)
        case (_, .compound(let ranimation, .parallel)):
            var animation = ranimation
            animation.insert(lhs, at: 0)
            return .compound(animations: animation, run: .parallel)
        default:
            return .compound(animations: [lhs, rhs], run: .parallel)
        }
    }
}

extension AnimationType: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = AnimationType
    public init(arrayLiteral elements: AnimationType...) {
        if let first = elements.first {
            if elements.count == 1 {
                self = first
            } else if case let .compound(animation, .sequential) = first {
                self = .compound(animations: animation + Array(elements.dropFirst(1)), run: .sequential)
            } else {
                self = .compound(animations: elements, run: .sequential)
            }
        } else {
            self = .none
        }
    }
}

