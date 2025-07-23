//
//  ActionCardSheetPresentable.swift
//  TymeComponent
//
//  Created by Tuan Pham on 20/04/2022.
//

import UIKit

public protocol TymeXActionCardSheetPresentable: TymeXActionModalPresentable {

    var cardSheetNavigationTitle: String { get }
    var hasCardSheetNavigation: Bool { get }
    var cardSheetNavigationView: UIView { get }
    var cardSheetNavigationHeight: CGFloat { get }
    var cardSheetShouldUseDynamicHeightHeader: Bool { get }
    var cardSheetShortFormHeight: TymeXActionModalHeight { get }
    var hasDimBackground: Bool { get }
    var cardSheetNavigationCofiguration: TymeXActionCardSheetNavigation.AppearanceConfiguration { get }
    var cardSheetFitFormHeight: TymeXActionModalHeight { get }

    func cardSheetStartMovingToShortForm()
    func cardSheetStartMovingToLongForm()
    func cardSheetStartMovingToFitForm()
    func cardSheetMovedToShortForm()
    func cardSheetMovedToLongForm()
    func cardSheetMovedToFitForm()
}
