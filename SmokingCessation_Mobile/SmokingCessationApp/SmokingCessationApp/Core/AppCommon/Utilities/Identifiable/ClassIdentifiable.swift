//
//  ClassIdentifiable.swift
//  SpreadsheetApp
//
//  Created by Dmitriy Petrov on 09/10/2019.
//  Copyright © 2019 BytePace. All rights reserved.
//

import UIKit

public protocol ClassIdentifiable: AnyObject {
    static var reuseId: String { get }
}

public extension ClassIdentifiable {
    static var reuseId: String {
        return String(describing: self)
    }
}
