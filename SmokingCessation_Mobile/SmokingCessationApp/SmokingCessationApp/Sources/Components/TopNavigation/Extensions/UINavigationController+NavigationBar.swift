//
//  UINavigationController+NavigationBar.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation

import UIKit

// MARK: - TymeXNavigationBarModeHandling
extension UINavigationController {
    func mxSetupBackgroundMode(_ mode: NavigationMode, isHiddenNav: Bool = false) {
        let tintColor = mode.tintColor
        let textColor = mode.textColor
        setNavigationBarHidden(isHiddenNav, animated: false)
        navigationBar.barTintColor = tintColor
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = nil
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = tintColor
            appearance.shadowImage = UIImage()
            appearance.shadowColor = nil
            appearance.titleTextAttributes = [:]
            appearance.largeTitleTextAttributes = [:]
            appearance.titleTextAttributes = [.foregroundColor: textColor]
            appearance.largeTitleTextAttributes = [.foregroundColor: textColor]
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
    }
}

extension UINavigationController {
    var mxHeightNavigationBar: CGFloat {
        return navigationBar.bounds.size.height
    }
}

// MARK: - TymeXNavigationBarBarButtonItemHandling
protocol NavigationBarBarButtonItemHandling {
    func mxSetupBarButtonItems(
        leftBarButtonTuple: BarButtonTuple,
        rightBarButtonTuple: BarButtonTuple
    )
}
extension UIViewController: NavigationBarBarButtonItemHandling {
    func mxSetupBarButtonItems(
        leftBarButtonTuple: BarButtonTuple,
        rightBarButtonTuple: BarButtonTuple
    ) {
        if let leftBarButton = leftBarButtonTuple.button {
            navigationItem.setLeftBarButtonItems([leftBarButton], animated: true)
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.hidesBackButton = true
            navigationItem.setLeftBarButtonItems([], animated: true)
        }
        if let rightBarButton = rightBarButtonTuple.button {
            navigationItem.setRightBarButtonItems([rightBarButton], animated: true)
        } else {
            navigationItem.rightBarButtonItem = nil
            navigationItem.setRightBarButtonItems([], animated: true)
        }
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
}
