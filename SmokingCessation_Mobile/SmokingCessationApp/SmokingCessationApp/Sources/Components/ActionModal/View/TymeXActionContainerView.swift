//
//  ActionContainerView.swift
//  ios-ui-components
//
//  Created by Duy Le on 18/06/2021.
//

import UIKit

/**
 A view wrapper around the presented view in a ActionModal transition.

 This allows us to make modifications to the presented view without
 having to do those changes directly on the view
 */
class TymeXActionContainerView: UIView {

    init(presentedView: UIView, frame: CGRect) {
        super.init(frame: frame)
        addSubview(presentedView)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension UIView {

    /**
     Convenience property for retrieving a ActionContainerView instance
     from the view hierachy
     */
    var mxActionContainerView: TymeXActionContainerView? {
        return subviews.first(where: { view -> Bool in
            view is TymeXActionContainerView
        }) as? TymeXActionContainerView
    }

}
