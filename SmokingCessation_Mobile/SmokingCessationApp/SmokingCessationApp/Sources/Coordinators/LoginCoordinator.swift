//
//  LoginCoordinator.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 3/6/25.
//

import UIKit
import Swinject

final class LoginCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let container: Container

    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        // Resolve ViewModel
        let viewModel = container.resolve(LoginViewModel.self)!

        // Create VC and assign both VM & coordinator
        let loginVC = LoginViewController()
        loginVC.viewModel = viewModel
        loginVC.coordinator = self

        // Push it onto the nav stack
        navigationController.setViewControllers([loginVC], animated: false)
    }

    func didLoginSuccessfully() {
        print("✅ didLoginSuccessfully() in LoginCoordinator")
        let homeTabBar = HomeTabBarController()
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.rootViewController = homeTabBar
            UIView.transition(
                with: window,
                duration: 1,
                options: .transitionCurlUp,
                animations: nil,
                completion: nil
            )
        }
    }
}



