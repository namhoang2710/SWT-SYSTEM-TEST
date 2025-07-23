//
//  TymeXSearchBarDelegate.swift
//  TymeXUIComponent
//
//  Created by Duc Nguyen on 24/5/24.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation

public protocol TymeXSearchBarDelegate: NSObjectProtocol {

    func searchBarShouldBeginEditing(_ searchBar: TymeXSearchBar) -> Bool
    func searchBarDidBeginEditing(_ searchBar: TymeXSearchBar)
    func searchBarShouldEndEditing(_ searchBar: TymeXSearchBar) -> Bool
    func searchBarDidEndEditing(_ searchBar: TymeXSearchBar)
    func searchBar(
        _ searchBar: TymeXSearchBar,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool
    func searchBarShouldClear(_ searchBar: TymeXSearchBar) -> Bool
    func searchBarShouldReturn(_ searchBar: TymeXSearchBar) -> Bool
    func searchBarShouldCancel(_ searchBar: TymeXSearchBar) -> Bool
    func searchBar(_ searchBar: TymeXSearchBar, textDidChange text: String)

}

public extension TymeXSearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: TymeXSearchBar) -> Bool {
        true
    }

    func searchBarDidBeginEditing(_ searchBar: TymeXSearchBar) {
        // Do nothing
    }

    func searchBarShouldEndEditing(_ searchBar: TymeXSearchBar) -> Bool {
        true
    }

    func searchBarDidEndEditing(_ searchBar: TymeXSearchBar) {
        // Do nothing
    }

    func searchBar(
        _ searchBar: TymeXSearchBar,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        true
    }

    func searchBarShouldClear(_ searchBar: TymeXSearchBar) -> Bool {
        true
    }

    func searchBarShouldReturn(_ searchBar: TymeXSearchBar) -> Bool {
        searchBar.searchTextField.resignFirstResponder()
        return true
    }

    func searchBarShouldCancel(_ searchBar: TymeXSearchBar) -> Bool {
        true
    }

    func searchBar(_ searchBar: TymeXSearchBar, textDidChange text: String) {
        // Do nothing
    }
}
