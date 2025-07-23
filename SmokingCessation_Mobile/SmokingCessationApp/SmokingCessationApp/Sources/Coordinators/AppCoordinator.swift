//
//  AppCoordinator.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 3/6/25.
//

import UIKit
import Swinject

protocol Coordinator {
    func start()
}

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let container: Container
    private var loginCoordinator: LoginCoordinator?

    init(window: UIWindow, container: Container) {
        self.window = window
        self.container = container
    }

    func start() {
        let navController = UINavigationController()
        window.rootViewController = navController
        window.makeKeyAndVisible()

        // Hand off to LoginCoordinator and RETAIN it
        let loginCoord = LoginCoordinator(navigationController: navController,
                                          container: container)
        self.loginCoordinator = loginCoord
        loginCoordinator?.start()
    }
}
