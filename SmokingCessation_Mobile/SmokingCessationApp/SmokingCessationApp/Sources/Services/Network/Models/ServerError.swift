//
//  ServerError.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

struct ServerError: Decodable, Error {
    let errorType: String
    let errorMessage: String
}

