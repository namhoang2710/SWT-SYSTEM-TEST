//
//  DictionaryExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import UIKit

public extension [NSAttributedString.Key: Any] {
    func color(_ color: UIColor) -> [NSAttributedString.Key: Any] {
        return self.with(key: .foregroundColor, value: color)
    }

    func paragraphStyle(
        lineSpacing: Double,
        alignment: NSTextAlignment
    ) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineBreakMode = .byTruncatingTail
        return self.with(key: .paragraphStyle, value: paragraphStyle)
    }

    func paragraphStyle(
        lineSpacing: Double,
        lineBreakMode: NSLineBreakMode,
        alignment: NSTextAlignment
    ) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineBreakMode = lineBreakMode
        return self.with(key: .paragraphStyle, value: paragraphStyle)
    }

    func makeParagraphStyle() -> NSMutableParagraphStyle {
        if let style = self[.paragraphStyle] as? NSParagraphStyle,
           let mutableStyle = style.mutableCopy() as? NSMutableParagraphStyle {
            return mutableStyle
        } else {
            return NSMutableParagraphStyle()
        }
    }

    func alignment(_ alignment: NSTextAlignment) -> [NSAttributedString.Key: Any] {
        let currentParagraphStyle = makeParagraphStyle()
        currentParagraphStyle.alignment = alignment
        return self.with(key: .paragraphStyle, value: currentParagraphStyle)
    }

    func lineHeightMultiple(_ lineHeightMultiple: CGFloat) -> [NSAttributedString.Key: Any] {
        let currentParagraphStyle = makeParagraphStyle()
        currentParagraphStyle.lineHeightMultiple = lineHeightMultiple
        return self.with(key: .paragraphStyle, value: currentParagraphStyle)
    }

    func with(key: NSAttributedString.Key, value: Value) -> [NSAttributedString.Key: Any] {
        return merging([key: value], uniquingKeysWith: { (_, last) in last })
    }
}

