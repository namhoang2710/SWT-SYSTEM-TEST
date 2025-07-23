//
//  DateExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 13/7/25.
//

import Foundation

public extension Date {
    func toString(
        dateFormat format: String,
        locale: Locale = Locale(identifier: "en_US_POSIX")
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

public extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }

    var startOfDay: Date {
        return Calendar(identifier: .gregorian).startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfDay) ?? Date()
    }
}
