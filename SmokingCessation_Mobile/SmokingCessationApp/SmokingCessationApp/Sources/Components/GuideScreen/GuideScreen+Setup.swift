//
//  GuideScreen+Setup.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import Lottie

extension GuideScreen {
    func setupViews() {
        view.backgroundColor = .white
        configNavigationBar()
        setupScrollView()
        setupTopContent()
        setupMainContent()
        setupButtonDockComponent()
    }

    func configNavigationBar() {
        guard guideScreenType == .fullScreen else { return }
        let leftItem: BarButtonItemStyle = (onLeftCompletion != nil) ? .icon(SmokingCessation().iconArrowLeft) : .empty
        let rightItem: BarButtonItemStyle = (onRightCompletion != nil) ? .icon(SmokingCessation().iconExit) : .empty
        let stylish = NavigationBarStylist(
            mode: .light(),
            center: .empty,
            left: leftItem,
            right: rightItem
        )
        mxApplyNavigationBy(
            stylist: stylish,
            leftAction: onLeftCompletion,
            rightAction: onRightCompletion
        )
    }

    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        if guideScreenType == .modal {
            scrollViewHeightConstraint = scrollView.heightAnchor
                .constraint(equalToConstant: 0)
            scrollViewHeightConstraint?.isActive = true
        }
    }

    func setupTopContent() {
        setupPictogram(topContentView: topContentView.topPictogramView)
        setupTopTitleStackView(title: topContentView.title, subTitle: topContentView.subTitle)
    }

    func setupPictogram(topContentView: UIView) {
        // Add topContentView to the scrollView
        topPictogramView = topContentView
        scrollView.addSubview(topContentView)
        topContentView.translatesAutoresizingMaskIntoConstraints = false
        // Set constraints for topContentView within the wrapper view
        NSLayoutConstraint.activate([
            topContentView.widthAnchor.constraint(equalToConstant: 120),
            topContentView.heightAnchor.constraint(equalToConstant: 120),
            topContentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            topContentView.topAnchor.constraint(
                equalTo: scrollView.topAnchor,
                constant: guideScreenType == .fullScreen ? 16 : 24
            )
        ])

        // If topContentView is a Lottie animation view, play the animation
        if let loadingView = topContentView as? Lottie.LottieAnimationView {
            loadingView.play(completion: nil)
        }
    }

    func setupTopTitleStackView(title: String, subTitle: String?) {
        guard let topPictogramView = self.topPictogramView else { return }
        // setup title and subtitle stack view
        let titleStackView = UIStackView()
        titleStackView.axis = .vertical
        titleStackView.spacing = 4
        titleStackView.alignment = .center
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleAndSubtitleStackView = titleStackView
        scrollView.addSubview(titleStackView)
        // title config
        titleStackView.addArrangedSubview(setupTitle(title: title))
        // subtitle config
        if let subTitle = subTitle, !subTitle.isEmpty {
            titleStackView.addArrangedSubview(setupSubtitle(subTitle: subTitle))
        }
        // constraints setting up
        NSLayoutConstraint.activate([
            titleStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            titleStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            titleStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            titleStackView.topAnchor.constraint(equalTo: topPictogramView.bottomAnchor, constant: 16)
        ])
    }

    private func setupTitle(title: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: SmokingCessation.textDisplayL.color(.black)
                .paragraphStyle(lineSpacing: 4, alignment: .center))
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityIdentifier = "titleLabel\(type(of: self))"
        topTitleLabel = titleLabel
        return titleLabel
    }

    private func setupSubtitle(subTitle: String) -> UILabel {
        let subTitleLabel = UILabel()
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.numberOfLines = 0
        subTitleLabel.attributedText = NSAttributedString(
            string: subTitle,
            attributes: SmokingCessation.textBodyDefaultL.color(.gray)
            .paragraphStyle(lineSpacing: 4, alignment: .center))
        subTitleLabel.accessibilityIdentifier = "subTitleLabel\(type(of: self))"
        topSubTitleLabel = subTitleLabel
        return subTitleLabel
    }

    func setupMainContent() {
        switch mainContentType {
        case .icon(let iconGuideLineContentList):
            setupIconMainContent(iconGuideLineContentList: iconGuideLineContentList)
        case .step(let stepGuideLineContentList):
            setupStepMainContent(stepGuideLineContentList: stepGuideLineContentList)
        default:
            return
        }
    }

    private func setupCustomSlotViewConstraints(mainContentList: UIView) {
        guard let customSlot = customSlotView else { return }
        customSlot.translatesAutoresizingMaskIntoConstraints = false
        mainContentList.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(customSlot)
        switch guideScreenType {
        case .fullScreen:
            setupCustomSlotFullScreenConstraints(customSlot: customSlot, mainContentList: mainContentList)
        case .modal:
            setupCustomSlotModalConstraints(customSlot: customSlot, mainContentList: mainContentList)
        default:
            return
        }
        NSLayoutConstraint.activate(customSlotConstraints)
    }

    private func setupCustomSlotFullScreenConstraints(customSlot: UIView, mainContentList: UIView) {
        guard let titleAndSubtitleStackView = titleAndSubtitleStackView else { return }
        customSlotConstraints = [
            customSlot.topAnchor.constraint(
                equalTo: titleAndSubtitleStackView.bottomAnchor,
                constant: 16
            ),
            customSlot.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            customSlot.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            customSlot.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            mainContentList.topAnchor.constraint(equalTo: customSlot.bottomAnchor, constant: 16),
            mainContentList.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainContentList.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainContentList.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16)
        ]
    }

    private func setupCustomSlotModalConstraints(customSlot: UIView, mainContentList: UIView) {
        guard let titleAndSubtitleStackView = titleAndSubtitleStackView else { return }
        customSlotConstraints = [
            mainContentList.topAnchor.constraint(
                equalTo: titleAndSubtitleStackView.bottomAnchor,
                constant: 16
            ),
            mainContentList.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainContentList.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            customSlot.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            customSlot.topAnchor.constraint(equalTo: mainContentList.bottomAnchor, constant: 16),
            customSlot.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            customSlot.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            customSlot.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16)
        ]
    }

    private func setupIconMainContent(iconGuideLineContentList: [IconGuidelineContent]) {
        let list = IconListView(iconListContent: iconGuideLineContentList)
        iconListView = list
        scrollView.addSubview(list)
        // set up constraints based on custom slot
        setupConstraintBasedOnSlot(mainContentList: list)
    }

    private func setupStepMainContent(stepGuideLineContentList: [StepGuidelineContent]) {
        let list = StepListView(
            stepListContent: stepGuideLineContentList,
            isTopLinePresented: isTopLinePresented,
            isBottomLinePresented: isBottomLinePresented
        )
        stepListView = list
        scrollView.addSubview(list)
        // set up constraints based on custom slot
        setupConstraintBasedOnSlot(mainContentList: list)
    }

    private func setupConstraintBasedOnSlot(mainContentList: UIView) {
        // set up constraints when there's custom slot
        if customSlotView != nil {
            setupCustomSlotViewConstraints(mainContentList: mainContentList)
        } else {
        // set up constraints when there's no custom slot
            setupMainContentConstraints(list: mainContentList)
        }
    }

    private func setupMainContentConstraints(list: UIView) {
        guard let titleAndSubtitleStackView = titleAndSubtitleStackView else { return }
        list.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: titleAndSubtitleStackView.bottomAnchor, constant: 16),
            list.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16)
        ])
    }

    func setupButtonDockComponent() {
        guard let buttonDockView = self.buttonDock else { return }
        view.addSubview(buttonDockView)
        buttonDockView.translatesAutoresizingMaskIntoConstraints = false

        if guideScreenType == .modal {
            // modal pin only to bottom of the safe area
            NSLayoutConstraint.activate([
                buttonDockView.leadingAnchor
                    .constraint(equalTo: view.leadingAnchor),
                buttonDockView.trailingAnchor
                    .constraint(equalTo: view.trailingAnchor),
                buttonDockView.bottomAnchor
                    .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else {
            // full-screen
            NSLayoutConstraint.activate([
                buttonDockView.topAnchor
                    .constraint(equalTo: scrollView.bottomAnchor),
                buttonDockView.leadingAnchor
                    .constraint(equalTo: view.leadingAnchor),
                buttonDockView.trailingAnchor
                    .constraint(equalTo: view.trailingAnchor),
                buttonDockView.bottomAnchor
                    .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }
}
