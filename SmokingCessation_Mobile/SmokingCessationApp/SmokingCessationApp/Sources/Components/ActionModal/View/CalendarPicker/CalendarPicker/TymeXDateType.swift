//
//  File.swift
//  GoTymeApp
//
//  Created by Vinh Pham on 22/06/2022.
//  Copyright © 2022 TymeDigital Vietnam. All rights reserved.
//

import Foundation

enum TymeXDateType {
    case year
    case month
    case day
    static var array: [TymeXDateType] {
        return [.year, .month, .day]
    }
}
