//
//  MXMotionEasing.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import Foundation
import UIKit

public enum MXMotionEasing {
    case motionEasingDefault
    case motionEasingSlowDown
    case motionEasingSpeedUp
    case undefined
}

extension MXMotionEasing: Hashable {
    public static func == (left: MXMotionEasing, right: MXMotionEasing) -> Bool {
        switch (left, right) {
        case (.undefined, .undefined):
            return true
        case (.undefined, _):
            return false
        case (_, .undefined):
            return false
        default:
            return left.caType == right.caType
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(caType)
    }
}

extension MXMotionEasing {
    public static func ?? (
        left: MXMotionEasing,
        right: @autoclosure () throws -> MXMotionEasing
    ) rethrows -> MXMotionEasing {
        if left == .undefined {
            return try right()
        } else {
            return left
        }
    }

}
extension MXMotionEasing {
    public var caType: CAMediaTimingFunction {
        switch self {
        case .motionEasingDefault:
            return .mxMotionEasingDefault
        case .motionEasingSpeedUp:
            return .mxMotionEasingSpeedUp
        case .motionEasingSlowDown:
            return .mxMotionEasingSlowDown
        case .undefined:
            return .mxMotionEasingDefault
        }
    }

    public var cubicTimingParameters: UICubicTimingParameters {
        switch self {
        case .motionEasingDefault:
            return .mxCubicTimingParametersDefault
        case .motionEasingSpeedUp:
            return .mxCubicTimingParametersSpeedUp
        case .motionEasingSlowDown:
            return .mxCubicTimingParametersSlowDown
        case .undefined:
            return .mxCubicTimingParametersDefault
        }
    }
}

public extension CAAnimation {
    // convenient setter, getter not implemented
    var timingFunctionType: MXMotionEasing? {
        get {
            fatalError("You cannot read timingFunctionType, read instead timingFunction.")
        }
        set {
            self.timingFunction = newValue?.caType
        }
    }
}

public extension CAKeyframeAnimation {
    var timingFunctionsType: [MXMotionEasing]? {
        get {
            fatalError("You cannot read timingFunctionType, read instead timingFunction.")
        }
        set {
            if let types = newValue {
                self.timingFunctions = types.map { $0.caType }
            } else {
                self.timingFunctions = nil
            }
        }
    }
}
