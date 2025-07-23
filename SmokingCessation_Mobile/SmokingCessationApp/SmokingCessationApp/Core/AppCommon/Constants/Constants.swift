//
//  Constants.swift
//  SmartApp
//
//  Created by SonTX on 10/29/19.
//  Copyright © 2019 Tyme Digital Viet Nam. All rights reserved.

import UIKit
import CoreLocation

public enum CoreConstants {
    public enum DateFormat {
        public static let monthDayYearHour = "MMMM dd, yyyy '.' h:mm:ss a"
        public static let monthAbrDayYearHour = "MMM dd, YYYY hh:mm a"
        public static let monthAbrDayYear = "MMM dd, YYYY"
        public static let dayMonthYearHour = "dd MMMM YYYY hh:mm:ss a"
        public static let yearMonthDay = "yyyy-MM-dd"
        public static let monthDayYear = "MMMM dd yyyy"
        public static let shortMonthDayYear = "MMM dd yyyy"
        public static let monthDayCommaYear = "MMMM d, yyyy"
        public static let monthDay = "MMMM d"
        public static let dayCommaYear = "d, yyyy"
        public static let month = "MMMM"
        public static let month2DayCommaYear = "MMMM dd, yyyy"
        public static let shortMonthDayYearHour = "MMMM dd yyyy 'at' hh:mm:ss a"
        public static let fullYearMonthDateTime = "yyyy-MM-dd hh:mm:ss"
        public static let hourOnly = "hh:mm aa"
        public static let weekday = "EEEE"
        public static let yearMonthDayHour = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        public static let yearOnly = "yyyy"
    }

    public enum SpecialCharacter {
        public static let space = " "
        public static let slash = "/"
        public static let asterisk = "*"
        public static let colon = ":"
        public static let ellipses = "..."
        public static let question = "?"
        public static let dollar = "$"
        public static let plus = "+"
        public static let peso = "₱"
        public static let newLine = "\n"
        public static let cString = "%s"
        public static let swiftString = "%@"
    }

    public enum Validation {
        public static let usernameMinLength = 8
        public static let passcodeMaxLength = 6
        public static let otpMaxLength = 6
        // swiftlint:disable line_length
        public static let emailPattern = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        public static let addressPattern =
            "[\\w\\p{P}]+(?:\\s[\\w\\p{P}]+)+"
        public static let numberPattern = ".*[0-9]+.*"
        public static let wordAndNumberPattern = "(?=.*[A-Za-z])(?=.*[0-9])"
        public static let cellPhoneFormat = "XXX XXX XXXX"
        public static let philNumberFormat = "^(0|\\+63)\\d{10}$"
    }

    public enum Tag {
        public static let expiredSessionTag = 28102022
    }

    public static let paragraph: String = "\u{2029}"

    public enum ErrorCode {
        public static let parsingErrorFail = "0400005"
    }

    public enum UserDefaultsKey {
        public static var enabledNFXLog: Bool {
            get {
                return UserDefaults.standard.bool(forKey: "enabledNFXLog")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "enabledNFXLog")
            }
        }

        public static var enabledMemoryLeakLog: Bool {
            get {
                return UserDefaults.standard.bool(forKey: "enabledMemoryLeakLog")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "enabledMemoryLeakLog")
            }
        }
    }
}
