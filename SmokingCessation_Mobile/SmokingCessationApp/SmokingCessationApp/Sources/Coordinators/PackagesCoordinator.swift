//
//  PackagesCoordinator.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 25/6/25.
//

import Foundation
import UIKit
import Swinject
import Lottie

final class PackagesCoordinator: Coordinator {
    private let navigationController: UINavigationController
       private let container: Container
       init(navigationController: UINavigationController, container: Container) {
           self.navigationController = navigationController
           self.container = container
       }
    func start() {
           let vm = container.resolve(PackagesViewModel.self)!
           let packageVC = PackagesViewController(viewModel: vm)
            packageVC.coordinator = self
        packageVC.tabBarItem = UITabBarItem(title: "Gói", image: SmokingCessation().iconStatement, tag: 2)
           navigationController.setViewControllers([packageVC], animated: false)
            
    }
    
    func showSuccessScreen(buyPackageResponse: BuyPackageResponse, package: PackageCard) {
        let dismissButton = PrimaryButton()
        dismissButton.setTitle(with: .text("Xác nhận"))
        dismissButton.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        let paymentSuccessAnimation: LottieAnimationView = {
            let anim = LottieAnimationView(name: SmokingCessation.paymentSuccessAnimation)
                       anim.contentMode = .scaleAspectFit
                       anim.loopMode = .loop
                        anim.play()
                       return anim
            }()
        var iconGuidelineContents: [IconGuidelineContent] =
            [
                IconGuidelineContent(title: "Gói \(package.title) với quyền lợi là \(package.numberDetails)", icon: .icAndroidFace),
                IconGuidelineContent(title: "Thông tin chi tiết", subTitle: "\(package.description)", icon: .icInfoFilled, isTitleHighlighted: true),
            ]
            if package.isBestValue {
                iconGuidelineContents.append(
                IconGuidelineContent(title: "Gói này là gói ưu đãi tốt nhất của chúng tôi", icon: .icCheckCircleInverse.withTintColor(.green), isTitleHighlighted: true)
                )
            }
            let guideScreenSuccess = GuideScreen(
            topContentView: GuideScreenTopView(
                topPictogramView: paymentSuccessAnimation,
                title: "Bạn đã thanh toán thành công gói: \(package.title)",
                subTitle: "Bạn sẽ được những quyền lợi sau đây:"
            ),
            mainContentType: .icon(iconGuidelineContents),
            buttonDock: ButtonDock(
                buttons: [
                    dismissButton
                ],
                displayMode: .alwayHideSeperator
            ))
        // Hide tab bar for this screen
        guideScreenSuccess.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(guideScreenSuccess, animated: true)
    }
}

extension PackagesCoordinator {
    @objc func backToHome() {
        // leave the "Gói" stack empty…
        navigationController.popToRootViewController(animated: false)
        // …then switch to Home tab (index 0 in HomeTabBarController)
        navigationController.tabBarController?.selectedIndex = 0
    }
}
