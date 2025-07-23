//
//  ActionModalPresenter.swift
//  ios-ui-components
//
//  Created by Duy Le on 18/06/2021.
//

import UIKit

/**
 A protocol for objects that will present a view controller as a ActionModal

 - Usage:
 ```
 viewController.presentActionModal(viewControllerToPresent: presentingVC,
                                             sourceView: presentingVC.view,
                                             sourceRect: .zero)
 ```
 */
protocol TymeXActionModalPresenter: AnyObject {

    /**
     A flag that returns true if the current presented view controller
     is using the ActionModalPresentationDelegate
     */
    var mxIsActionModalPresented: Bool { get }

    /**
     Presents a view controller that conforms to the ActionModalPresentable protocol
     */
    func mxPresentActionModal(
        _ viewControllerToPresent: TymeXActionModalPresentable.TymeXLayoutType,
        sourceView: UIView?,
        sourceRect: CGRect,
        completion: (() -> Void)?
    )
}
