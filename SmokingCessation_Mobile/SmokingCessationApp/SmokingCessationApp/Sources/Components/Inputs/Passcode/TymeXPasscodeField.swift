//
//  TymeXPasscodeField.swift
//  TymeXUIComponent
//
//  Created by Ngoc Truong on 30/12/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public class TymeXPasscodeField: UIView {
    var isFilled: Bool = false

    enum PasscodeState {
        case defaultState, filledState, errorState
    }

    struct ConstantsPasscodeField {
        static let normalBackgroundColor = SmokingCessation.colorBackgroundInfoStrong
        static let filledBackgroundColor = SmokingCessation.colorIconSelection
        static let errorBackgroundColor = SmokingCessation.colorBackgroundErrorBase
        static let circleDefaultSize: CGFloat = 12
        static let circleFilledSize: CGFloat = 16
    }

    var currentState: PasscodeState = .defaultState {
        didSet { updateStyleForState() }
    }

    lazy var circleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = ConstantsPasscodeField.circleDefaultSize / 2
        view.backgroundColor = ConstantsPasscodeField.normalBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        setupCircleView()
    }

    private func setupCircleView() {
        addSubview(circleView)
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: ConstantsPasscodeField.circleDefaultSize),
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor),
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func updateStyleForState() {
        switch currentState {
        case .defaultState:
            circleView.backgroundColor = ConstantsPasscodeField.normalBackgroundColor
        case .filledState:
            circleView.backgroundColor = ConstantsPasscodeField.filledBackgroundColor
        case .errorState:
            circleView.backgroundColor = ConstantsPasscodeField.errorBackgroundColor
        }
    }
}
