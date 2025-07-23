//
//  PurchasedPackagesResponse.swift
//  SmokingCessationApp
//
//  Created by AI on 26/6/25.
//

import Foundation

struct PurchasedPackage: Decodable {
    let id: Int
    let accountId: Int
    let infoPackageId: Int
    let name: String
    let price: Decimal
    let purchaseDate: String
}

struct PurchasedPackagesResponse: Decodable {
    let accountId: Int
    let purchasedPackages: [PurchasedPackage]
} 