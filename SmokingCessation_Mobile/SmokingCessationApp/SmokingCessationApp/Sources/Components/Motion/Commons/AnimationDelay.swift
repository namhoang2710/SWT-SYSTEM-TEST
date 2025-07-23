//
//  AnimationDelay.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

public enum AnimationDelay: CaseIterable {
    case delay1
    case delay2
    case delay3
    case delay4
    case delay5
    case delay6
    case delay7
    case undefined

    public var value: Double {
        switch self {
        case .delay1:
            return SmokingCessation.motionDelay1/1000.0
        case .delay2:
            return SmokingCessation.motionDelay2/1000.0
        case .delay3:
            return SmokingCessation.motionDelay3/1000.0
        case .delay4:
            return SmokingCessation.motionDelay4/1000.0
        case .delay5:
            return SmokingCessation.motionDelay5/1000.0
        case .delay6:
            return SmokingCessation.motionDelay6/1000.0
        case .delay7:
            return SmokingCessation.motionDelay7/1000.0
        case .undefined:
            return 0.0
        }
    }

    public static var allValues: [AnimationDelay] {
        let values = AnimationDelay.allCases.map { $0 }
        return values.sorted { $0.value < $1.value }
    }
}
