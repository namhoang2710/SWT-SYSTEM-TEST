//
//  ArrayExt.swift
//  GoTymeApp
//
//  Created by Duy Le on 21/11/2022.
//  Copyright © 2022 TymeDigital Vietnam. All rights reserved.
//

import Foundation

// MARK: Check array containsSameElements with another array
public extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

public extension Array {
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }

    mutating func removeSafe(at index: Int) {
        guard index >= 0 && index < endIndex else { return }
        remove(at: index)
    }
}

public extension Array where Element == URLQueryItem {
    func convertToDictionary() -> [String: Any]? {
        var dictionary = [String: Any]()
        for queryItem in self {
            if let value = queryItem.value {
                dictionary[queryItem.name] = value
            }
        }
        return dictionary.isEmpty ? nil : dictionary
    }
}
