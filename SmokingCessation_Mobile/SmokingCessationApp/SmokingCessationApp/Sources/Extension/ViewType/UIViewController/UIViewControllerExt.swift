//
//  UIViewControllerExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit
import ToastViewSwift

extension UIViewController {
    func showToastMessage(message: String,subTitle: String? = nil, animationTime: TimeInterval = 0.2, icon: UIImage? = nil, direction: Toast.Direction? = nil) {
        let config = ToastConfiguration(
            direction: direction ?? .bottom,
            dismissBy: [.time(time: 2.5),
                .swipe(direction: .natural), .longPress],
            animationTime: 0.2
        )
        let toast = Toast.default(
            image: icon ?? .icAndroidFaceInverse,
            title: message,
            subtitle: subTitle ?? ""
        , config: config)
        toast.show()
    }
}
