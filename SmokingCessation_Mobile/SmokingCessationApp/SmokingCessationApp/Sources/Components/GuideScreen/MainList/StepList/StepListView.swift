//
//  StepListView.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import UIKit

public class StepListView: UIView {
    var stepListContent: [StepGuidelineContent]
    var stepListCellView: [StepListCellView] = []
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public init(stepListContent: [StepGuidelineContent], isTopLinePresented: Bool?, isBottomLinePresented: Bool?) {
        self.stepListContent = stepListContent
        super.init(frame: .zero)
        setupStackView()
        configureStepList(isTopLinePresented: isTopLinePresented, isBottomLinePresented: isBottomLinePresented)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupStackView() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func configureStepList(isTopLinePresented: Bool?, isBottomLinePresented: Bool?) {
        for (index, content) in stepListContent.enumerated() {
            print("Adding cell at index: \(index)")
            let cell = StepListCellView(
                stepGuidelineContent: content,
                index: index,
                isTopLinePresented: isTopLinePresented,
                isBottomLinePresented: isBottomLinePresented,
                totalCount: stepListContent.count
            )
            stepListCellView.append(cell)
            stackView.addArrangedSubview(cell)
        }
    }
}
