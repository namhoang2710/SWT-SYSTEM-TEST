//
//  SelectionCardBadgeText.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit

// MARK: - Badge Text Attachment
class TymeXSelectionCardBadgeText: NSTextAttachment {
    private let text: String
    private let textAttributes: [NSAttributedString.Key: Any]
    private let backgroundColor: UIColor
    private let cornerRadius: CGFloat
    private let padding: UIEdgeInsets
    init(
        text: String,
        textAttributes: [NSAttributedString.Key: Any],
        backgroundColor: UIColor,
        cornerRadius: CGFloat = 4,
        padding: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    ) {
        self.text = text
        self.textAttributes = textAttributes
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        super.init(data: nil, ofType: nil)
        self.image = renderBadgeImage()
        // Adjust vertical alignment
        if let image = self.image {
            let baselineOffset = (image.size.height - text.size(withAttributes: textAttributes).height) / 2
            self.bounds = CGRect(
                x: 0,
                y: -baselineOffset,
                width: image.size.width,
                height: image.size.height
            )
        }
    }

    // code coverage tool ignore
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func renderBadgeImage() -> UIImage? {
        // Calculate the size of the badge
        let textSize = text.size(withAttributes: textAttributes)
        let badgeWidth = textSize.width + padding.left + padding.right
        let badgeHeight = textSize.height + padding.top + padding.bottom
        // Create a drawing context
        let badgeSize = CGSize(width: badgeWidth, height: badgeHeight)
        UIGraphicsBeginImageContextWithOptions(badgeSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        // Draw the background
        let badgeRect = CGRect(origin: .zero, size: badgeSize)
        let path = UIBezierPath(roundedRect: badgeRect, cornerRadius: cornerRadius)
        backgroundColor.setFill()
        path.fill()
        // Draw the text
        let textRect = badgeRect.inset(by: padding)
        (text as NSString).draw(in: textRect, withAttributes: textAttributes)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

