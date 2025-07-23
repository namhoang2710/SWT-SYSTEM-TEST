//
//  ActionCardSheetPresentable+Defaults.swift
//  TymeComponent
//
//  Created by Tuan Pham on 20/04/2022.
//

import UIKit

public extension TymeXActionCardSheetPresentable where Self: UIViewController {

    typealias CardSheetLayoutType = TymeXActionCardSheetPresentable & UIViewController

    var cardSheetNavigationTitle: String {
        return ""
    }

    var hasCardSheetNavigation: Bool {
        return false
    }

    var cardSheetNavigationView: UIView {
        let view = TymeXActionCardSheetNavigation()
        view.configure(cardSheetNavigationCofiguration)
        view.setTitle(cardSheetNavigationTitle)
        return view
    }

    var cardSheetNavigationCofiguration: TymeXActionCardSheetNavigation.AppearanceConfiguration {
        return .init(backgroundColor: .black, tintColor: .white)
    }

    var cardSheetNavigationHeight: CGFloat {
        return 64.0
    }

    var cardSheetShouldUseDynamicHeightHeader: Bool {
        return false
    }

    var cardSheetShortFormHeight: TymeXActionModalHeight {
        return .contentHeight(88)
    }

    var cardSheetNavigationColor: UIColor {
        return .black
    }

    func cardSheetStartMovingToShortForm() {
        // The default handle should be empty
    }

    func cardSheetStartMovingToLongForm() {
        // The default handle should be empty
    }

    func cardSheetMovedToShortForm() {
        // The default handle should be empty
    }

    func cardSheetMovedToLongForm() {
        // The default handle should be empty
    }
}
