//
//  BlogsCoordinator.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 27/6/25.
//

import Foundation
import Swinject

final class BlogsCoordinator: Coordinator {
    private let navigationController: UINavigationController
       private let container: Container
       init(navigationController: UINavigationController, container: Container) {
           self.navigationController = navigationController
           self.container = container
       }
    func start() {
        //           let vm = container.resolve(BookingViewModel.self)!
        let blogsVC = BlogListViewController()
        blogsVC.coordinator = self
        blogsVC.tabBarItem = UITabBarItem(title: "Trang chủ",
                                          image: UIImage(systemName: "house.fill"),
                                          tag: 0)
        navigationController.setViewControllers([blogsVC], animated: false)
    }
}

