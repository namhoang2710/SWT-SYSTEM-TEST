//
//  GuidelineCell.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import UIKit
import Foundation

public class GuideLineCell: UIStackView {
    private let topLine: UIView = {
        let view = UIView()
        view.backgroundColor = SmokingCessation.secondaryColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = SmokingCessation.secondaryColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = SmokingCessation.secondaryColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = GuideScreen.ConstantsGuideScreen.stepNumberCircleSize / 2
        return view
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "guideLineCellNumberLabelTymeXGuideScreen"
        return label
    }()

    public init(guidelineCellType: GuideLineCellType, showTopLine: Bool?, showBottomLine: Bool?) {
        super.init(frame: .zero)
        axis = .vertical
        alignment = .center
        spacing = 0
        distribution = .fill
        setupViews(guidelineCellType: guidelineCellType)
        setLinesShown(top: showTopLine, bottom: showBottomLine)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Set up views
    private func setupViews(guidelineCellType: GuideLineCellType) {
        setupTopLine()
        setupCircleOrIcon(guidelineCellType: guidelineCellType)
    }

    private func setupTopLine() {
        addArrangedSubview(topLine)
        NSLayoutConstraint.activate([
            topLine.heightAnchor.constraint(
                equalToConstant: GuideScreen.ConstantsGuideScreen.stepperTopLineHeight),
            topLine.widthAnchor.constraint(
                equalToConstant: GuideScreen.ConstantsGuideScreen.stepperLineWidth)
        ])
    }

    func updateBottomLineHeight(containerHeight: CGFloat) {
        let remainingHeight = containerHeight -
        (GuideScreen.ConstantsGuideScreen.stepNumberCircleSize +
         GuideScreen.ConstantsGuideScreen.stepperTopLineHeight)
        NSLayoutConstraint.activate([
            bottomLine.heightAnchor.constraint(equalToConstant: remainingHeight),
            bottomLine.widthAnchor.constraint(equalToConstant: GuideScreen.ConstantsGuideScreen.stepperLineWidth)
        ])
        addArrangedSubview(bottomLine)
    }

    private func setupCircleOrIcon(guidelineCellType: GuideLineCellType) {
        switch guidelineCellType {
        case .stepper(let number):
            setNumber(number)
            setupStepperGuidelineCell()
        case .icon(let iconImage):
            iconImage.translatesAutoresizingMaskIntoConstraints = false
            iconImage.accessibilityIdentifier = "guideLineCellIconImageTymeXGuideScreen"
            addArrangedSubview(iconImage)
            NSLayoutConstraint.activate([
                iconImage.widthAnchor.constraint(
                    equalToConstant: GuideScreen.ConstantsGuideScreen.stepNumberCircleSize),
                iconImage.heightAnchor.constraint(
                    equalToConstant: GuideScreen.ConstantsGuideScreen.stepNumberCircleSize)
            ])
        }
    }

    private func setupStepperGuidelineCell() {
        addArrangedSubview(circleView)
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(
                equalToConstant: GuideScreen.ConstantsGuideScreen.stepNumberCircleSize),
            circleView.heightAnchor.constraint(
                equalToConstant: GuideScreen.ConstantsGuideScreen.stepNumberCircleSize)
        ])
        circleView.addSubview(numberLabel)
        NSLayoutConstraint.activate([
            numberLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
        ])
    }

    func setNumber(_ number: Int) {
        numberLabel.attributedText = NSAttributedString(string: "\(number)", attributes: SmokingCessation.textBodyEmphasizeS
            .color(.black)
            .alignment(.center)
        )
    }

    func setLinesShown(top: Bool?, bottom: Bool?) {
        topLine.alpha = (top ?? false) ? 1.0 : 0.0
        bottomLine.alpha = (bottom ?? false) ? 1.0 : 0.0
    }

}
