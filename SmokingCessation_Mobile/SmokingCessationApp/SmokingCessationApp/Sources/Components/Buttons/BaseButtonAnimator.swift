//
//  BaseButtonAnimator.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import UIKit
import Lottie

final class BaseButtonAnimator {
    func highlightView(
        _ backgroundView: UIView,
        isHighlighted: Bool,
        configuration: HighlightViewConfiguration
    ) {
        let animationLayer = AnimationMaker().makeButtonHighlightBackground(
            fromColor: isHighlighted ? configuration.normalColor : configuration.highlightedColor,
            toColor: isHighlighted ? configuration.highlightedColor : configuration.normalColor,
            bounds: backgroundView.bounds,
            cornerRadius: configuration.cornerRadius
        )
        backgroundView.layer.sublayers?.removeAll(where: {
            $0.name == animationLayer.name
        })
        backgroundView.layer.insertSublayer(animationLayer, at: 0)
        backgroundView.mxBorderWidth = isHighlighted ?
        configuration.highlightedBorderWidth : configuration.normalBorderWidth
    }

    func makeLoadingContentView(lottieAnimationName: String) -> UIView? {
        let animationView = LottieAnimationView(
            animation: .named(lottieAnimationName, bundle: BundleSmokingCessation.bundle)
        )
        animationView.loopMode = .loop
        animationView.play(completion: nil)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        return animationView
    }

    func showLoading(
        minWidth: CGFloat,
        views: LoadingViews,
        completion: @escaping () -> Void
    ) {
        views.animationContainerView.alpha = 0

        UIView.animate(
            withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [],
            animations: {
                views.button.layoutIfNeeded()
            }, completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    views.button.animContainerView.alpha = 1
                    completion()
                }
            }
        )

        UIView.animate(
            withDuration: 0.25, delay: 0,
            animations: {
                views.titleView.alpha = 0
                let size = views.titleView.bounds.size
                views.titleLabel.transform = CGAffineTransform(
                    translationX: -(size.width - views.titleLabel.frame.size.width)/2, y: 0
                )
                views.titleIcon.transform = CGAffineTransform(
                    translationX: (size.width - views.titleIcon.frame.size.width)/2, y: 0
                )
            },
            completion: { _ in
                views.titleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
                views.titleIcon.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        )
    }
}

// MARK: - HighlightViewConfiguration
struct HighlightViewConfiguration {
    var normalColor: UIColor
    var highlightedColor: UIColor
    var cornerRadius: CGFloat
    var highlightedBorderWidth: CGFloat
    var normalBorderWidth: CGFloat
}

struct LoadingViews {
    var button: BaseButton
    var animationContainerView: UIView
    var animatedWidth: NSLayoutConstraint?
    var backgroundView: UIView
    var titleView: UIView
    var titleLabel: UIView
    var titleIcon: UIImageView
}
