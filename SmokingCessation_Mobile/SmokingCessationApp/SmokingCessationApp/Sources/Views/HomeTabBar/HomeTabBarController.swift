//
//  HomeTabBarController.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 3/6/25.
//

import UIKit

/// A simple Tab Bar with two tabs: "Home" and "Profile".
/// Replace these with your real view controllers as needed.
final class HomeTabBarController: UITabBarController {

    // Keep a strong reference so it isn't deallocated
    private var packageCoordinator: PackagesCoordinator?
    private var bookingCoordinator: BookingCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    private func setupTabBar() {

        
        // 1. Home Screen
        let homeVC = BlogListViewController()
        homeVC.view.backgroundColor = .systemBackground
        homeVC.tabBarItem = UITabBarItem(title: "Trang chủ",
                                         image: UIImage(systemName: "house.fill"),
                                         tag: 0)
        let bookingVC = BookingViewController()
        bookingVC.tabBarItem = UITabBarItem(title: "Đặt lịch",
                                             image: SmokingCessation().iconCalendar,
                                             tag: 1)
        let packageVC = PackagesViewController()
        packageVC.tabBarItem = UITabBarItem(title: "Gói", image: SmokingCessation().iconStatement, tag: 2)
        // 2. Profile Screen (example)
        let profileVC = ProfileViewController()
        profileVC.view.backgroundColor = .systemBackground
        profileVC.tabBarItem = UITabBarItem(title: "Profile",
                                            image: .icUserInverse,
                                            tag: 3)
        // If you want each tab to be embedded in its own NavigationController:
        let homeNav = UINavigationController(rootViewController: homeVC)
        let bookingNav = UINavigationController(rootViewController: bookingVC)
        let profileNav = UINavigationController(rootViewController: profileVC)
        let packageNav = UINavigationController(rootViewController: packageVC)
        let pkgCoord = PackagesCoordinator(navigationController: packageNav, container: DIContainer.shared.container)
        pkgCoord.start()
        let bookingCoord = BookingCoordinator(navigationController: bookingNav, container: DIContainer.shared.container)
        bookingCoord.start()
        // retain it
        self.packageCoordinator = pkgCoord
        self.bookingCoordinator = bookingCoord
        viewControllers = [homeNav,bookingNav, packageNav, profileNav]

        // Optional: customize tab bar appearance
        tabBar.tintColor = .accent
        tabBar.backgroundColor = .none
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()          // removes blur
        appearance.backgroundColor = .systemGray6           // the grouped-table grey
        appearance.stackedLayoutAppearance.selected.iconColor   = .accent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.accent]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance        // iOS 15+
        }
    }
}

