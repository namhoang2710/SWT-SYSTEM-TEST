//
//  UIImageExt.swift
//  TymeXUIComponent
//
//  Created by Duc Nguyen on 24/5/24.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import UIKit

extension UIImage {
    class func mxImageWithSolidColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    func mxRoundedImage(with cornerRadius: CGFloat, cornersToRound: UIRectCorner) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIBezierPath(roundedRect: rect,
                     byRoundingCorners: cornersToRound,
                     cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).addClip()
        draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    /// Function to generate an circular-shape looked UIImage with inner and outer circles
    /// - Parameters:
    ///   - outerDiameter: The outer circle's diameter
    ///   - innerDiameter: The innter circle's diamter
    ///   - innerColor: the color of the inner circle
    ///   - outerColor: the color of the outer circle
    /// - Returns: An UIImage that look like a circle with a circle inside
    class func mxMakeThumbImage(
        outerDiameter: CGFloat = 32,
        innerDiameter: CGFloat = 24,
        innerColor: UIColor = SmokingCessation.colorBackgroundPrimaryBase,
        outerColor: UIColor = SmokingCessation.colorStrokeWhite
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: outerDiameter, height: outerDiameter),
            format: UIGraphicsImageRendererFormat.default()
        )
        let img = renderer.image { ctx in
            // Outer “border” circle
            outerColor.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero,
                                                 size: CGSize(width: outerDiameter,
                                                              height: outerDiameter)))
            // Inner filled circle (centered)
            let inset = (outerDiameter - innerDiameter) / 2
            innerColor.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: inset,
                                                 y: inset,
                                                 width: innerDiameter,
                                                 height: innerDiameter))
        }
        return img.withRenderingMode(.alwaysOriginal)
    }

}
