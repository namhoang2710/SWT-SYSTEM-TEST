//
//  CardSheetContainer+Layout.swift
//  TymeComponent
//
//  Created by Tuan Pham on 20/04/2022.
//

import UIKit

extension TymeXActionCardSheetContainerController {
    internal func layoutViews() {
        layoutBackgroundView()
        layoutMainContainerView()
        layoutDragIndicatorView()

        layoutContentContainerView()
        layoutNavigationView()
        layoutContentView()
    }

    private func layoutBackgroundView() {
        guard presentable.hasDimBackground else { return }
        visualEffectView.frame = parentController.view.frame
        visualEffectView.isHidden = true
        visualEffectView.backgroundColor = presentable.mxActionModalBackgroundColor
        parentController.view.addSubview(visualEffectView)

        guard presentable.mxAllowsTapToDismiss else { return }
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(didTapDimmedBackgroud(_:)))
        visualEffectView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func didTapDimmedBackgroud(_: UITapGestureRecognizer) {
        presentable.cardSheetStartMovingToShortForm()
        transision(to: .shortForm, duration: 0.7)
    }

    private func layoutMainContainerView() {
        view.addSubview(mainContainerStackView)
        mainContainerStackView.mxFillSuperview()
    }

    private func layoutDragIndicatorView() {
        if presentable.mxShowDragIndicator {
            indicatorContainerView.heightAnchor.constraint(equalToConstant: 24).isActive = true

            indicatorContainerView.addSubview(dragIndicatorView)

            dragIndicatorView.backgroundColor = presentable.mxDragIndicatorBackgroundColor
            dragIndicatorView.centerXAnchor.constraint(equalTo: indicatorContainerView.centerXAnchor).isActive = true
            dragIndicatorView.centerYAnchor.constraint(equalTo: indicatorContainerView.centerYAnchor).isActive = true
            dragIndicatorView.heightAnchor.constraint(
                equalToConstant: Constants.dragIndicatorSize.height
            ).isActive = true
            dragIndicatorView.widthAnchor.constraint(equalToConstant: Constants.dragIndicatorSize.width).isActive = true

            mainContainerStackView.addArrangedSubview(indicatorContainerView)
        }
    }

    private func layoutContentContainerView() {
        mainContainerStackView.addArrangedSubview(contentContainerStackView)
    }

    private func layoutNavigationView() {

        let hasNavigation = presentable.hasCardSheetNavigation
        let navigationView = presentable.cardSheetNavigationView
        let navigationHeight = presentable.cardSheetNavigationHeight

        guard hasNavigation else { return }
        contentContainerStackView.addArrangedSubview(navigationView)

        if !presentable.cardSheetShouldUseDynamicHeightHeader {
            navigationView.heightAnchor.constraint(equalToConstant: navigationHeight).isActive = true
        }

        navigationView.addGestureRecognizer(panGestureRecognizer)
    }

    private func layoutContentView() {

        addChild(contentController)
        contentContainerStackView.addArrangedSubview(contentController.view)
        contentController.didMove(toParent: self)

//        view.addGestureRecognizer(panGestureRecognizer)
    }
}
