//
//  File.swift
//  GoTymeApp
//
//  Created by Vinh Pham on 22/06/2022.
//  Copyright © 2022 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public extension TymeXCalendarPickerView {
    enum TymeXLocalizeType {
        case enLocale
        static func localize(locale: Locale?) -> TymeXLocalizeType {
            return .enLocale
        }

        func dateArray(_ dateFormatType: TymeXDateFormatType) -> [TymeXDateType] {
            if dateFormatType == .default {
                return [.month, .day, .year]
            } else {
                return [.month, .year]
            }
        }

        func width(dateType: TymeXDateType, isShowWeek: Bool) -> CGFloat {
            switch self {
            default:
                if dateType == .month {
                    return 100.5
                } else if dateType == .year {
                    return 100.5
                } else {
                    if isShowWeek {
                        return 75
                    } else {
                        return 54
                    }
                }
            }
        }

        func alignment(dateType: TymeXDateType) -> NSTextAlignment {
            switch self {

            default:
                if dateType == .year {
                    return .center
                } else if dateType == .month {
                    return .left
                } else {
                    return .center
                }
            }
        }

        func dateIndex(_ dateType: TymeXDateType, dateFormatType: TymeXDateFormatType) -> Int {
            return self.dateArray(dateFormatType).firstIndex(where: { $0 == dateType }) ?? 0
        }

        func year(_ value: Int) -> String {
            switch self {
            case .enLocale:
                return "\(value + 1)"
            }
        }

        func month(_ value: Int) -> String {
            switch self {
            case .enLocale:
                let months = ["January", "February", "March", "April",
                              "May", "June", "July", "August", "September", "October", "November", "December"]
                return "\(months[value])"
            }
        }

        func day(_ value: Int) -> String {
            switch self {
            case .enLocale:
                return "\(value + 1)"
            }
        }
    }

}
