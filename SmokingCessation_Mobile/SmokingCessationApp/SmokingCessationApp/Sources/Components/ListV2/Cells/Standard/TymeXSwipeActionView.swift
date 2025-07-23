//
//  FavoriteActionView.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 16/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit
import Lottie

enum TymeXSwipeActionState: String {
    case favoriteForm = "payment-success"
    case favoriteBurst = "anim_favorite_burst"
    case redHeart = "anim_red_heart"
    case unfavoriteBurst = "anim_unfavorite_burst"
    case unfavoriteForm = "anim_unfavorite_form"
}

public class TymeXSwipeActionView: UIView {
    // Favorite state
    var isFavorite: Bool = false {
        didSet {
            updateAnimationStyle()
        }
    }

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = SmokingCessation.spacing2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "Favorite", attributes: SmokingCessation.textTitleS)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let lottieAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(
            animation: .named(
                TymeXSwipeActionState.favoriteForm.rawValue,
                bundle: BundleSmokingCessation.bundle
            )
        )
        animationView.contentMode = .scaleAspectFit
        return animationView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.backgroundColor = SmokingCessation.colorBackgroundDarkBase
        addSubview(stackView)

        stackView.addArrangedSubview(lottieAnimationView)
        stackView.addArrangedSubview(titleLabel)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: SmokingCessation.spacing4),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: 0)
        ])
    }

    private func updateAnimationStyle() {
        // Stop current animation
       lottieAnimationView.stop()

       // Set currentProgress = 0
       lottieAnimationView.currentProgress = 0

        // Update animation based on favorite state
        let animationName: String = isFavorite ?
        TymeXSwipeActionState.unfavoriteForm.rawValue : TymeXSwipeActionState.favoriteForm.rawValue
        lottieAnimationView.animation = LottieAnimation.named(animationName, bundle: BundleSmokingCessation.bundle)
    }

    func playLottieFromCurrentProgress(_ currentProgress: CGFloat, toProgress: CGFloat) {
        lottieAnimationView.play(fromProgress: currentProgress, toProgress: toProgress)
    }

    func playLottie(for state: TymeXSwipeActionState, completion: LottieCompletionBlock?) {
        lottieAnimationView.animation = LottieAnimation.named(state.rawValue, bundle: BundleSmokingCessation.bundle)
        lottieAnimationView.play(completion: completion)
    }

    func updateTitle(title: String) {
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: SmokingCessation.textTitleS.color(SmokingCessation.colorTextInverse)
        )
    }
}
