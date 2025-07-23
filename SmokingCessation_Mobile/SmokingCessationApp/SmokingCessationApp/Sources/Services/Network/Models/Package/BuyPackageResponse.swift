//
//  BuyPackageResponse.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 23/6/25.
//

import Foundation

struct BuyPackageResponse: Decodable {
    let packageId: Int
    let packageName: String
    let price: Decimal
    let accountId: Int
    let message: String
    let purchaseDate: String
}
