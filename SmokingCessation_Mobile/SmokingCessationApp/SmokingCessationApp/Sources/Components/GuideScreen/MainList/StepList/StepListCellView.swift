//
//  StepListCellView.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

public class StepListCellView: UIStackView {
    public let isFirst: Bool
    public let isLast: Bool
    public let index: Int
    var guideLineLeftView: GuideLineCell?
    var guideLineContent: GuideLineContent?
    // Store the content container as a property
    private let contentViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public init(
        stepGuidelineContent: StepGuidelineContent,
        index: Int,
        isTopLinePresented: Bool?,
        isBottomLinePresented: Bool?,
        totalCount: Int
    ) {
        self.index = index
        self.isFirst = index == 0
        self.isLast = index == totalCount - 1
        let finalTopLinePresented = !isFirst || (isTopLinePresented ?? false)
        let finalBottomLinePresented = !isLast || (isBottomLinePresented ?? false)
        super.init(frame: .zero)
        axis = .horizontal
        distribution = .fill
        alignment = .leading
        spacing = 16
        setupStepListLeftView(
            isTopLinePresented: finalTopLinePresented,
            isBottomLinePresented: finalBottomLinePresented
        )
        setupContentView(stepGuidelineContent: stepGuidelineContent)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupContentView(stepGuidelineContent: StepGuidelineContent) {
        // Use the property contentViewContainer here
        addArrangedSubview(contentViewContainer)
        let guidelineContent = GuideLineContent(
            title: stepGuidelineContent.title,
            subTitle: stepGuidelineContent.subTitle,
            isTitleHighlighted: stepGuidelineContent.isTitleHighlighted
        )
        guidelineContent.translatesAutoresizingMaskIntoConstraints = false
        guideLineContent = guidelineContent
        contentViewContainer.addSubview(guidelineContent)
        NSLayoutConstraint.activate([
            guidelineContent.topAnchor.constraint(equalTo: contentViewContainer.topAnchor, constant: 16),
            guidelineContent.bottomAnchor.constraint(
                equalTo: contentViewContainer.bottomAnchor, constant: -16
            ),
            guidelineContent.leadingAnchor.constraint(equalTo: contentViewContainer.leadingAnchor),
            guidelineContent.trailingAnchor.constraint(equalTo: contentViewContainer.trailingAnchor)
        ])
    }

    func setupStepListLeftView(isTopLinePresented: Bool, isBottomLinePresented: Bool) {
        let leftView = GuideLineCell(
            guidelineCellType: .stepper(number: index + 1),
            showTopLine: isTopLinePresented,
            showBottomLine: isBottomLinePresented
        )
        guideLineLeftView = leftView
        addArrangedSubview(leftView)
        leftView.translatesAutoresizingMaskIntoConstraints = false
        leftView.widthAnchor.constraint(
            equalToConstant: GuideScreen.ConstantsGuideScreen.stepNumberCircleSize
        ).isActive = true
    }

    // Override layoutSubviews to update bottom line height after layout has been performed
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        let containerHeight = contentViewContainer.frame.height
        guideLineLeftView?.updateBottomLineHeight(containerHeight: containerHeight)
    }
}
