//
//  CardSheetContainer+PresentationStyle.swift
//  TymeComponent
//
//  Created by Tuan Pham on 20/04/2022.
//

import Foundation

extension TymeXActionCardSheetContainerController {
    public enum PresentationState {
        case shortForm
        case longForm
        case fitForm

        var nextState: PresentationState {
            switch self {
            case .shortForm:
                return .longForm
            case .longForm:
                return .shortForm
            case .fitForm:
                return .fitForm
            }
        }
    }
}
