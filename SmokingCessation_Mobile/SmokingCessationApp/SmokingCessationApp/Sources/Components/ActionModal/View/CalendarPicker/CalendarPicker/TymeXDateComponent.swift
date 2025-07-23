//
//  DateComponent.swift
//  GoTymeApp
//
//  Created by Vinh Pham on 22/06/2022.
//  Copyright © 2022 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public struct TymeXDateComponent {
    public var year: Int = 0
    public var month: Int = 0
    public var day: Int = 0
    public var hour: Int = 0
    public var minute: Int = 0
    public var second: Int = 0

    public var date: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        // swiftlint:disable:next line_length
        return dateFormatter.date(from: "\(self.yearString)-\(self.monthString)-\(self.dayString) \(self.hourString):\(self.minuteString):\(self.secondString)")
    }

    public var week: TymeXWeekday? {
        guard let date = self.date else { return nil }
        let calendar = Calendar.current
        let week = (calendar as NSCalendar).components(.weekday, from: date).weekday ?? 0
        return TymeXWeekday.array[week - 1]
    }

    public var yearString: String {
        return "\(self.year)"
    }

    public var monthString: String {
        return self.month < 10 ? "0\(self.month)" : "\(self.month)"
    }

    public var dayString: String {
        return self.day < 10 ? "0\(self.day)" : "\(self.day)"
    }

    public var hourString: String {
        return self.hour < 10 ? "0\(self.hour)" : "\(self.hour)"
    }

    public var minuteString: String {
        return self.minute < 10 ? "0\(self.minute)" : "\(self.minute)"
    }

    public var secondString: String {
        return self.second < 10 ? "0\(self.second)" : "\(self.second)"
    }

    public init() { }

    mutating func reset() {
        self.year = 0
        self.month = 0
        self.day = 0
        self.hour = 0
        self.minute = 0
        self.second = 0
    }

    func equalYear(_ value: TymeXDateComponent?) -> Bool {
        guard let value = value else { return false }
        return self.year == value.year
    }

    func equalYearMonth(_ value: TymeXDateComponent?) -> Bool {
        guard let value = value else { return false }
        return self.year == value.year && self.month == value.month
    }

    func equalDate(_ value: TymeXDateComponent?) -> Bool {
        guard let value = value else { return false }
        return self.year == value.year && self.month == value.month && self.day == value.day
    }

    static func dateEqual(lhs: TymeXDateComponent, rhs: TymeXDateComponent) -> Bool {
        if lhs.year == rhs.year &&
            lhs.month == rhs.month &&
            lhs.day == rhs.day &&
            lhs.week == rhs.week &&
            lhs.yearString == rhs.yearString &&
            lhs.monthString == rhs.monthString &&
            lhs.dayString == rhs.dayString {
            return true
        } else {
            return false
        }
    }

    public static func == (lhs: TymeXDateComponent, rhs: TymeXDateComponent) -> Bool {
        if lhs.year == rhs.year &&
            lhs.month == rhs.month &&
            lhs.day == rhs.day &&
            lhs.hour == rhs.hour &&
            lhs.minute == rhs.minute &&
            lhs.second == rhs.second {
            return true
        } else {
            return false
        }
    }
}
