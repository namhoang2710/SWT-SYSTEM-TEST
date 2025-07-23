//
//  UIButtonExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 13/7/25.
//

import Foundation
import UIKit

extension UIButton {
    func addImage(_ image: UIImage?, contentMode: UIView.ContentMode = .scaleAspectFill) {
        // remove old subviews in case of any
        self.subviews.forEach { $0.removeFromSuperview() }

        // create UIImageView contain image
        let imageView = UIImageView(image: image)
        imageView.contentMode = contentMode
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Add UIImageView into UIButton
        self.addSubview(imageView)

        // Establish constraints for UIImageView
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.45),
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.45)
        ])
    }

    func findImage() -> UIImage? {
        // Iterate through the subviews of the UIButton
        for subview in self.subviews {
            // Check if the subview is a UIImageView
            if let imageView = subview as? UIImageView {
                // Return the image from the UIImageView
                return imageView.image
            }
        }
        // Return nil if no UIImageView is found
        return nil
    }
}
