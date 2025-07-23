//
//  Package.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation

struct Package: Decodable {
    let id: Int
    let name: String
    let price: Decimal
    let duration: Int
    let description: String
    let numberOfConsultations: Int
    let numberOfHealthCheckups: Int
}
