//
//  UIDeviceExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

extension UIDevice {
    var hasHomeIndicator: Bool {
        return (UIApplication.shared.windows
            .filter({ $0.isKeyWindow })
            .first?.safeAreaInsets.bottom ?? 0) > 0
    }

    var safeAreaInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.mxKeyWindow
            return window?.safeAreaInsets ?? .zero
        }
        return .zero
    }

    var safeAreaInsetBottom: CGFloat {
        return safeAreaInset.bottom
    }
}

