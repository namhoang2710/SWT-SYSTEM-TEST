//
//  UIApplicationExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import UIKit

public extension UIApplication {
    var mxKeyWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            return connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else if #available(iOS 13.0, *) {
            return windows.first { $0.isKeyWindow }
        } else {
            return keyWindow
        }
    }
}
