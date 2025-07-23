//
//  ActionModalPresentable+LayoutHelpers.swift
//  ios-ui-components
//
//  Created by Duy Le on 18/06/2021.
//

import UIKit

/**
 ⚠️ [Internal Only] ⚠️
 Helper extensions that handle layout in the ActionModalPresentationController
 */
extension TymeXActionModalPresentable where Self: UIViewController {

    /**
     Cast the presentation controller to ActionModalPresentationController
     so we can access ActionModalPresentationController properties and methods
     */
    var presentedVC: TymeXActionModalPresentationController? {
        return presentationController as? TymeXActionModalPresentationController
    }

    /**
     Length of the top layout guide of the presenting view controller.
     Gives us the safe area inset from the top.
     */
    var topLayoutOffset: CGFloat {

        guard let rootVC = rootViewController
            else { return 0 }

        if #available(iOS 11.0, *) {
            return rootVC.view.safeAreaInsets.top
        } else {
            return rootVC.topLayoutGuide.length
        }
    }

    /**
     Length of the bottom layout guide of the presenting view controller.
     Gives us the safe area inset from the bottom.
     */
    var bottomLayoutOffset: CGFloat {

       guard let rootVC = rootViewController
            else { return 0 }

        let defaultBottomPadding: CGFloat = 16
        if #available(iOS 11.0, *) {
            return max(rootVC.view.safeAreaInsets.bottom, defaultBottomPadding)
        } else {
            return rootVC.bottomLayoutGuide.length
        }
    }

    /**
     Returns the short form Y position

     - Note: If voiceover is on, the `longFormYPos` is returned.
     We do not support short form when voiceover is on as it would make it difficult for user to navigate.
     */
    var shortFormYPos: CGFloat {

        guard !UIAccessibility.isVoiceOverRunning
            else { return longFormYPos }

        let shortFormYPos = topMargin(from: mxShortFormHeight) + mxTopOffset
        // shortForm shouldn't exceed longForm
        return max(shortFormYPos, longFormYPos)
    }

    /**
     Returns the long form Y position

     - Note: We cap this value to the max possible height
     to ensure content is not rendered outside of the view bounds
     */
    var longFormYPos: CGFloat {
        return max(topMargin(from: mxLongFormHeight), topMargin(from: .maxHeightDefault)) + mxTopOffset
    }
    /**
     Returns the loading form Y position

     - Note: We cap this value to the loading state possible height
     to ensure content is not rendered outside of the view bounds
     */
    var loadingFormYPos: CGFloat {
        guard !UIAccessibility.isVoiceOverRunning
            else { return longFormYPos }

        let loadingFormYPos = topMargin(from: mxLoadingFormHeight) + mxTopOffset
        // shortForm shouldn't exceed longForm
        return max(loadingFormYPos, longFormYPos)
    }

    /**
     Use the container view for relative positioning as this view's frame
     is adjusted in ActionModalPresentationController
     */
    var bottomYPos: CGFloat {

        guard let container = presentedVC?.containerView
            else { return view.bounds.height }

        return container.bounds.size.height - mxTopOffset
    }

    /**
     Converts a given action modal height value into a y position value
     calculated from top of view
     */
    func topMargin(from: TymeXActionModalHeight) -> CGFloat {
        switch from {
        case .maxHeightDefault:
            return 44.0
        case .maxHeightWithTopInset(let inset):
            return inset
        case .contentHeight(let height):
            return bottomYPos - (height + bottomLayoutOffset)
        case .contentHeightIgnoringSafeArea(let height):
            return bottomYPos - height
        case .intrinsicHeight:
            view.layoutIfNeeded()
            let targetSize = CGSize(width: (presentedVC?.containerView?.bounds ?? UIScreen.main.bounds).width,
                                    height: UIView.layoutFittingCompressedSize.height)
            let intrinsicHeight = view.systemLayoutSizeFitting(targetSize).height
            return bottomYPos - (intrinsicHeight + bottomLayoutOffset)
        }
    }

    private var rootViewController: UIViewController? {

        guard let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as? UIApplication
            else { return nil }

        return application.mxKeyWindow?.rootViewController
    }

}
