//
//  CardSheetConfigurable.swift
//  TymeComponent
//
//  Created by Tuan Pham on 20/04/2022.
//

import UIKit

public protocol TymeXCardSheetConfigurable: AnyObject {
    var contentController: TymeXActionCardSheetPresentable.CardSheetLayoutType { get }
    var parentController: UIViewController { get }
}

extension TymeXCardSheetConfigurable where Self: UIViewController {
    var mxCardSheetShortFormValue: CGFloat {

        let shortFormHeight = contentController.cardSheetShortFormHeight
        switch shortFormHeight {
        case .contentHeight(let height):
            return height
        case .contentHeightIgnoringSafeArea(let inset):
            return parentController.view.bounds.height - inset

        case .intrinsicHeight:
            return 68

        case .maxHeightDefault:
            return parentController.view.bounds.height

        case .maxHeightWithTopInset(let inset):
            return parentController.view.bounds.height - inset
        }
    }

    var mxCardSheetLongFormValue: CGFloat {

        let longFormHeight = contentController.mxLongFormHeight
        let maxHeight = parentController.view.bounds.height

        switch longFormHeight {
        case .contentHeight(let height):
            return height
        case .contentHeightIgnoringSafeArea(let inset):
            return maxHeight - inset

        case .intrinsicHeight:
            return 68

        case .maxHeightDefault:
            return maxHeight

        case .maxHeightWithTopInset(let inset):
            return maxHeight - inset
        }
    }

    var mxCardSheetShortFormYPos: CGFloat {
        let shortFormHeight = contentController.cardSheetShortFormHeight
        let bottomLayoutOffset = contentController.bottomLayoutOffset

        let maxHeight = parentController.view.bounds.height

        switch shortFormHeight {
        case .contentHeight(let height):
            return maxHeight - height

        case .contentHeightIgnoringSafeArea(let inset):
            return maxHeight - inset

        case .intrinsicHeight:
            return maxHeight

        case .maxHeightDefault:
            return 0.0

        case .maxHeightWithTopInset(let inset):
            return maxHeight - bottomLayoutOffset - inset
        }
    }

    var mxCardSheetFitFormYPos: CGFloat {
        let shortFormHeight = contentController.cardSheetFitFormHeight
        let bottomLayoutOffset = contentController.bottomLayoutOffset

        let maxHeight = parentController.view.bounds.height

        switch shortFormHeight {
        case .contentHeight(let height):
            return maxHeight - height

        case .contentHeightIgnoringSafeArea(let inset):
            return maxHeight - inset

        case .intrinsicHeight:
            return maxHeight

        case .maxHeightDefault:
            return 0.0

        case .maxHeightWithTopInset(let inset):
            return maxHeight - bottomLayoutOffset - inset
        }
    }

    var mxCardSheetLongFormYPos: CGFloat {
        let longFormHeight = contentController.mxLongFormHeight
        let bottomLayoutOffset = contentController.bottomLayoutOffset

        let maxHeight = parentController.view.bounds.height

        switch longFormHeight {
        case .contentHeight(let height):
            return maxHeight - height

        case .contentHeightIgnoringSafeArea(let inset):
            return maxHeight - inset

        case .intrinsicHeight:
            return maxHeight

        case .maxHeightDefault:
            return 0.0

        case .maxHeightWithTopInset(let inset):
            return bottomLayoutOffset + inset
        }
    }
}
