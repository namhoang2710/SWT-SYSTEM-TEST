//
//  TymeXSlider+Enum.swift
//  TymeXUIComponent
//
//  Created by Duy Huynh on 21/4/25.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation

public enum TymeXSliderValueType: Equatable {
    case integer
    case decimal(places: Int?)

    /// The “default” decimal mode (places == nil)
    public static let decimal: TymeXSliderValueType = .decimal(places: nil)
}
