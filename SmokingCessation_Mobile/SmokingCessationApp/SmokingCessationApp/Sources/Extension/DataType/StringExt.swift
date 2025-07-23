//
//  StringExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import UIKit
import CoreImage

public extension String {
    /// Remove all whitespace from a string
    var removeWhitespace: String {
        let space = " "
        return replacingOccurrences(of: space, with: "")
    }

    var length: Int {
        return count
    }

    func isValidEmail() -> Bool {
        let emailPred = NSPredicate(format: "SELF MATCHES %@", CoreConstants.Validation.emailPattern)
        let lowerStr = self.lowercased()
        return emailPred.evaluate(with: lowerStr)
    }

    func addErrorCode(with code: String?) -> String {
        guard let code = code else { return self }
        return self + CoreConstants.paragraph + "code: \(code)"
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript(_ idx: Int) -> String {
        let idx1 = index(startIndex, offsetBy: idx)
        let idx2 = index(idx1, offsetBy: 1)
        return String(self[idx1..<idx2])
    }

    subscript (range: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start ..< end])
    }

    subscript (range: CountableClosedRange<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: range.upperBound - range.lowerBound)
        return String(self[startIndex...endIndex])
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    func toBarcodeNumber() -> String {
        enumerated().reduce("") {
            if $1.0 == 3 || $1.0 == 7 || $1.0 == 11 {
                return $0 + String($1.1) + " "
            } else {
                return $0 + String($1.1)
            }
        }
    }

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func uint8Array() -> [UInt8] {
        var retVal: [UInt8] = []
        for thing in self.utf8 {
            retVal.append(UInt8(thing))
        }
        return retVal
    }

    enum ExtendedEncoding {
        case hexadecimal
    }

    func data(using encoding: ExtendedEncoding) -> Data? {
        let hexStr = self.dropFirst(self.hasPrefix("0x") ? 2 : 0)

        guard hexStr.count % 2 == 0 else { return nil }

        var newData = Data(capacity: hexStr.count / 2)

        var indexIsEven = true
        for index in hexStr.indices {
            if indexIsEven {
                let byteRange = index...hexStr.index(after: index)
                guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
                newData.append(byte)
            }
            indexIsEven.toggle()
        }
        return newData
    }

    var letterCount: Int {
        return self.unicodeScalars.filter({ CharacterSet.letters.contains($0) }).count
    }

    var digitCount: Int {
        return self.unicodeScalars.filter({ CharacterSet.decimalDigits.contains($0) }).count
    }

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

    func localized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: "")
    }

    func isAlphabetCharacters() -> Bool {
        return self.range(of: "[^a-zA-Z]", options: .regularExpression) == nil && self != ""
    }

    func hasSameDigits() -> Bool {
        let firstDigit = self[0]
        for value in self where String(value) != firstDigit {
            return false
        }
        return true
    }

    func isMatches(for regex: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(
                in: self,
                range: NSRange(self.startIndex..., in: self)
            )
            return !results.isEmpty
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }

    func substring(string: String, fromIndex: Int, toIndex: Int) -> String? {
        if fromIndex < toIndex && toIndex < string.count /*use string.characters.count for swift3*/{
            let startIndex = string.index(string.startIndex, offsetBy: fromIndex)
            let endIndex = string.index(string.startIndex, offsetBy: toIndex)
            return String(string[startIndex..<endIndex])
        } else {
            return nil
        }
    }

    func isHTTPLinkURL() -> Bool {
        let fouthFirstString = self.prefix(4).lowercased()
        return fouthFirstString == "http"
    }

    func replaceFirst(
        of pattern: String,
        with replacement: String
    ) -> String {
          if let range = self.range(of: pattern) {
            return self.replacingCharacters(in: range, with: replacement)
          }
        return self
    }

    func removeWhiteSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }

    func toInt() -> Int? {
        return Int(self)
    }

    func toInt64() -> Int64? {
        return Int64(self)
    }

    func toDouble() -> Double {
        if let double = Double(self) {
            return double
        }
        return Double(0)
    }

    func toFloat() -> Float64? {
        if let float = Float64(self) {
            return float
        }
        return Float64(0)
    }

    func toDate(
        withFormat format: String = CoreConstants.DateFormat.yearMonthDay,
        timeZone: String
    ) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: timeZone)
        let date = dateFormatter.date(from: self)
        return date
    }

    func abbreviation() -> String {
        let arr = self.components(separatedBy: " ")
        var abbre = ""
        for str in arr {
            if let char = str.first {
                abbre += String(char)
            }
        }
        return abbre
    }

    func removeFirstCharacter() -> String {
        let result = String(self.dropFirst())
        return result
    }

    func removeSubString(string: String) -> String {
        let result = self.replacingOccurrences(of: string, with: "")
        return result
    }

    func reduceWith(threshold: Int) -> String {
        if self.count > threshold {
            return self[0..<threshold] + "..."
        }
        return self
    }

    func getLastURLPath() -> String? {
        var lastPathComponent: String?
        if let url = URL(string: self) {
            lastPathComponent = url.lastPathComponent
        }
        return lastPathComponent
    }

    func attributedString(
        font: UIFont,
        underlineStyle: NSUnderlineStyle = NSUnderlineStyle(rawValue: 0),
        color: UIColor = UIColor.black
    ) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        attributedString.append(
            NSMutableAttributedString(
                string: self,
                attributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: color,
                    NSAttributedString.Key.underlineStyle: underlineStyle.rawValue]
            )
        )
        return attributedString
    }

    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> Data {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return data
        }
        return Data()
    }

    func base64DecodedString() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    func trimmingWhiteSpace() -> String {
        return components(separatedBy: .whitespaces).filter { !$0.isEmpty }.joined(separator: " ")
    }

    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to ind: Int) -> String {
        let toIndex = index(from: ind)
        return String(self[..<toIndex])
    }

    func substring(with range: Range<Int>) -> String {
        let startIndex = index(from: range.lowerBound)
        let endIndex = index(from: range.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

public extension String {

    /// Creates a QR code for the current URL in the given color.
//    func qrImage(color: UIColor = UIColor.black, logo: UIImage? = nil) -> CIImage? {
//        let tintedQRImage = qrImage?.tinted(using: color)
//
//        guard let logo = logo?.cgImage else {
//            return tintedQRImage
//        }
//
//        return tintedQRImage?.combined(with: CIImage(cgImage: logo))
//    }

    /// Returns a black and white QR code for this URL.
    var qrImage: CIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let qrData = data(using: String.Encoding.ascii)
        qrFilter.setValue(qrData, forKey: "inputMessage")

        let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
        return qrFilter.outputImage?.transformed(by: qrTransform)
    }
}

extension String {
    func stringByFilteringSpecialCharacter() -> String {
        let pattern = "[^A-Za-z0-9\\s_.,()-]"
        return filteringCharacter(with: pattern)
    }

    func filteringCharacter(with pattern: String) -> String {
        let mStr = NSMutableString(string: self)
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: mStr.length)
            regex.replaceMatches(in: mStr, options: [], range: range, withTemplate: "")
            return String(mStr).replacingOccurrences(of: "  ", with: " ")
        } catch { return "" }
    }

    func count(of char: Character) -> Int {
        return reduce(0) {
            $1 == char ? $0 + 1 : $0
        }
    }

    func indexInt(of char: Character) -> Int? {
        return firstIndex(of: char)?.utf16Offset(in: self)
    }

    func toCurrencyValue(decimalSymbol: String) -> Double {
        let charsSet = CharacterSet(charactersIn: "0123456789\(decimalSymbol)").inverted
        var value = components(separatedBy: charsSet).joined()
        if decimalSymbol != "." {
            value = value.replacingOccurrences(of: decimalSymbol, with: ".")
        }
        return Double(value) ?? 0.00
    }

    func toCurrencyValue(decimalSymbol: Character) -> Double {
        return toCurrencyValue(decimalSymbol: String(decimalSymbol))
    }

    func containsRange(_ range: NSRange) -> Bool {
        return Range(range, in: self) != nil
    }

    func getInitialsName() -> String {
        if isEmpty {
            return ""
        }

        // Trimming whitespace characters from the string
        let trimmedString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = trimmedString.components(separatedBy: " ")

        if components.count > 1 {
            // For multi-word names, take the first letter of the first two components
            let initials = components.compactMap { $0.first }.prefix(2)
            return initials.map { String($0) }.joined().uppercased()
        } else {
            // For single-word names, take the first two letters, or one if the name is shorter
            return String(trimmedString.prefix(2)).uppercased()
        }
    }
}

extension String {
    func count(of string: String) -> Int {
        return components(separatedBy: string).count - 1
    }
}

extension String {
    public var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    public func applyPatternOnNumbers(pattern: String) -> String {
        let replacmentCharacter: Character = "#"
        let pureNumber = self.replacingOccurrences(of: "[^۰-۹0-9]", with: "", options: .regularExpression)
        var result = ""
        var pureNumberIndex = pureNumber.startIndex
        for patternCharacter in pattern {
            if patternCharacter == replacmentCharacter {
                guard pureNumberIndex < pureNumber.endIndex else { return result }
                result.append(pureNumber[pureNumberIndex])
                pureNumber.formIndex(after: &pureNumberIndex)
            } else {
                result.append(patternCharacter)
            }
        }

        return result
    }
}

extension String {
    public func fillteringCharacter(with pattern: String) -> String {
        let mStr = NSMutableString(string: self)
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: mStr.length)
            regex.replaceMatches(in: mStr, options: [], range: range, withTemplate: "")
            return String(mStr).replacingOccurrences(of: "  ", with: " ")
        } catch { return "" }
    }
}

extension String {
    var isBlank: Bool {
      return allSatisfy({ $0.isWhitespace })
    }
}

extension String {
    func toTymeQRCode() -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
