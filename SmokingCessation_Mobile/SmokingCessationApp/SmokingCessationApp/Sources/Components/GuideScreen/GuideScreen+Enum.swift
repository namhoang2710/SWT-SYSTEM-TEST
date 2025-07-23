//
//  GuideScreen+Enum.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation

/// enum defining types of presenting a guide screen
@frozen
public enum GuideScreenType: CaseIterable {
    /// presented full screen mode
    case fullScreen
    /// presented modal mode
    case modal

    public func getGuideScreenType() -> String {
        switch self {
        case .fullScreen:
            return "Full screen"
        case .modal:
            return "Modal"
        }
    }
}

/// enum defining guideline content type
public enum GuideScreenMainViewType {
    case step([StepGuidelineContent])
    case icon([IconGuidelineContent])
}

