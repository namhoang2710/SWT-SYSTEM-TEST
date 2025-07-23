//
//  TymeXListStandardCell+Animation.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 07/01/2025.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit
import Lottie

// MARK: - Binding
extension TymeXListStandardCell {
    func playRedHeartAnimation() {
        if let trailingLottieAnimationView = trailingView as? LottieAnimationView {
            let isFavorite = model?.trailingStatus?.isFavorite() ?? false
            if isFavorite {
                trailingLottieAnimationView.animation = LottieAnimation.named(
                    TymeXSwipeActionState.redHeart.rawValue,
                    bundle: BundleSmokingCessation.bundle
                )
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//                    trailingLottieAnimationView.play()
//                })
                trailingLottieAnimationView.play()
            }
        }
    }

    func animateScaleDownAndDisappear(
        view: UIView,
        duration: TimeInterval = 2.0, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut]) {
            view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            view.alpha = 0
        } completion: { _ in
            view.isHidden = true
            completion?()
        }
    }
}
