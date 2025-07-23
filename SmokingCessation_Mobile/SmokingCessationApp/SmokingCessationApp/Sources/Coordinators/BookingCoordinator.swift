//
//  BookingCoordinator.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 27/6/25.
//

import UIKit
import Swinject


final class BookingCoordinator: Coordinator {
    private let navigationController: UINavigationController
       private let container: Container
       init(navigationController: UINavigationController, container: Container) {
           self.navigationController = navigationController
           self.container = container
       }
    func start() {
        //           let vm = container.resolve(BookingViewModel.self)!
        let bookingVC = BookingViewController()
        bookingVC.coordinator = self
        bookingVC.tabBarItem = UITabBarItem(title: "Đặt lịch",
                                             image: SmokingCessation().iconCalendar,
                                             tag: 1)
        navigationController.setViewControllers([bookingVC], animated: false)
    }
}
