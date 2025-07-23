//
//  DateComponent+Week.swift
//  GoTymeApp
//
//  Created by Vinh Pham on 22/06/2022.
//  Copyright © 2022 TymeDigital Vietnam. All rights reserved.
//
import Foundation

public extension TymeXDateComponent {
    enum TymeXWeekday {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday

        static var array: [TymeXWeekday] {
            return [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        }

        public func value(_ value: TymeXCalendarPickerView.TymeXLocalizeType) -> String {
            switch value {
            case .enLocale:
                switch self {
                case .monday: return "Monday"
                case .tuesday: return "Tuesday"
                case .wednesday: return "Wenday"
                case .thursday: return "Thursday"
                case .friday: return "Friday"
                case .saturday: return "Saturday"
                case .sunday: return "Sunday"
                }
            }
        }

        public static func == (lhs: TymeXWeekday, rhs: TymeXWeekday) -> Bool {
            switch (lhs, rhs) {
            case (.monday, .monday): return true
            case (.tuesday, .tuesday): return true
            case (.wednesday, .wednesday): return true
            case (.thursday, .thursday): return true
            case (.friday, .friday): return true
            case (.saturday, .saturday): return true
            case (.sunday, .sunday): return true
            default: return false
            }
        }
    }

}
