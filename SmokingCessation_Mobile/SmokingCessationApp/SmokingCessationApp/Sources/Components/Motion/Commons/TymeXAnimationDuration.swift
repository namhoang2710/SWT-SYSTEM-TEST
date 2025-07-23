//
//  TymeXAnimationDuration.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

public enum AnimationDuration: CaseIterable {
    case duration1
    case duration2
    case duration3
    case duration4
    case duration5
    case duration6

    public var value: Double {
        switch self {
        case .duration1:
            return SmokingCessation.motionDuration1/1000.0
        case .duration2:
            return SmokingCessation.motionDuration2/1000.0
        case .duration3:
            return SmokingCessation.motionDuration3/1000.0
        case .duration4:
            return SmokingCessation.motionDuration4/1000.0
        case .duration5:
            return SmokingCessation.motionDuration5/1000.0
        case .duration6:
            return SmokingCessation.motionDuration6/1000.0
        }
    }

    public static var allValues: [AnimationDuration] {
        let values = AnimationDuration.allCases.map { $0 }
        return values.sorted { $0.value < $1.value }
    }
}
