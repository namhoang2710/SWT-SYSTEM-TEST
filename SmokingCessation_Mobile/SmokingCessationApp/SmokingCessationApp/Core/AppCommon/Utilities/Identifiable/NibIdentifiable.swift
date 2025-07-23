//
//  NibIdentifiable.swift
//  SpreadsheetApp
//
//  Created by Dmitriy Petrov on 07/10/2019.
//  Copyright © 2019 BytePace. All rights reserved.
//

import UIKit

public protocol NibIdentifiable: AnyObject {
    static var nib: UINib { get }
}

public extension NibIdentifiable {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

public extension NibIdentifiable where Self: UIView {
    static func initFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("Couldn't find nib file for \(self)")
        }

        return view
    }

    func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Error loading \(self) from nib")
        }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            view.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        } else {
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        }
        if #available(iOS 11.0, *) {
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        } else {
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        }
        if #available(iOS 11.0, *) {
            view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        } else {
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        }
        if #available(iOS 11.0, *) {
            view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        }
    }
}

extension NibIdentifiable where Self: UITableView {
    static func initFromNib() -> Self {
        guard let tableView = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("Couldn't find nib file for \(self)")
        }

        return tableView
    }
}

extension NibIdentifiable where Self: UICollectionView {
    static func initFromNib() -> Self {
        guard let collectionView = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("Couldn't find nib file for \(self)")
        }

        return collectionView
    }
}

extension NibIdentifiable where Self: UIViewController {
    static func initFromNib() -> Self {
        return Self(nibName: nibIdentifier, bundle: nil)
    }

    static func initFromNib(withName name: String) -> Self {
        return Self(nibName: name, bundle: nil)
    }
}

extension UIViewController: NibIdentifiable {
    public static var nibIdentifier: String {
        return String(describing: self)
    }
}
