//
//  LoadingView.swift
//  SmartApp
//
//  Created by Son Teemo on 10/28/19.
//  Copyright © 2019 Tyme Digital. All rights reserved.
//

import UIKit
import Lottie

public class TymeXLoadingView: UIControl {

    public lazy var animatedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addSubview(animatedView)
        backgroundColor = .darkGray.withAlphaComponent(0.3)

        // Set up constraints
        NSLayoutConstraint.activate([
            animatedView.widthAnchor.constraint(equalToConstant: 24),
            animatedView.heightAnchor.constraint(equalToConstant: 24),
            animatedView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animatedView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    public func showAnimatedLoading(lottieAnimationName: String, bundle: Bundle) {
        let animationView = LottieAnimationView(animation: .named(lottieAnimationName, bundle: bundle))
        animationView.loopMode = .loop
        animationView.play(completion: nil)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.accessibilityIdentifier = "animationViewTymeXLoadingView"
        animatedView.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: animatedView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: animatedView.bottomAnchor),
            animationView.leftAnchor.constraint(equalTo: animatedView.leftAnchor),
            animationView.rightAnchor.constraint(equalTo: animatedView.rightAnchor)
        ])
    }

}
