//
//  ButtonDockStatus.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation

public enum TermsFeeStatus {
    case terms(String, Bool)
    case fee([FeeModel])
    case none
}
