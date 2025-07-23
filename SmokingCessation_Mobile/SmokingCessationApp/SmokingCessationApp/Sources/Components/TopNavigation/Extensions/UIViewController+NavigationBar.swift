//
//  UIViewController+NavigationBar.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import UIKit

// MARK: - TymeXNavigationBar Apply style
public extension UIViewController {
    static let mxHeightNaviBar: CGFloat = 44.0
    func mxApplyNavigationBy(
        stylist: NavigationBarStylist?,
        leftAction: TymeXCompletion? = nil,
        rightAction: TymeXCompletion? = nil,
        isHiddenNav: Bool = false
    ) {
        guard let stylist = stylist else { return }
        navigationController?.mxSetupBackgroundMode(stylist.mode, isHiddenNav: isHiddenNav)
        let heightNaviBar = navigationController?.mxHeightNavigationBar ?? UIViewController.mxHeightNaviBar
        let leftBarButtonTuple = stylist.left.makeBarButtonTuple(
            action: leftAction,
            mode: stylist.mode,
            heightNaviBar: heightNaviBar,
            type: .left
        )
        let rightBarButtonTuple = stylist.right.makeBarButtonTuple(
            action: rightAction,
            mode: stylist.mode,
            heightNaviBar: heightNaviBar,
            type: .right
        )
        mxSetupBarButtonItems(
            leftBarButtonTuple: leftBarButtonTuple,
            rightBarButtonTuple: rightBarButtonTuple
        )
        let maxWidthOfBarButtons = max(leftBarButtonTuple.width, rightBarButtonTuple.width)
        navigationItem.titleView = stylist.center.makeTitleView(
            heightNaviBar: heightNaviBar,
            maxWidthOfBarButtons: maxWidthOfBarButtons,
            mode: stylist.mode
        )
    }
}
