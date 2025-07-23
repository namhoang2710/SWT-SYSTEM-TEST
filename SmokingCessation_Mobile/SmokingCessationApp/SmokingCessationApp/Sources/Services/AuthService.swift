//
//  AuthService.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 3/6/25.
//

import Foundation
import RxSwift

protocol AuthServiceProtocol {
    /// Attempts login with provided credentials. Returns access token String.
    func login(email: String, password: String) -> Single<String>
    /// Register new account, completes on success
    func register(email: String, password: String, name: String, age: Int, gender: String) -> Single<Void>
    /// Performs logout on server. Emits completion on success.
    func logout() -> Single<Void>
    /// Verifies the given code. Completes on success.
    func verify(code: String) -> Single<Void>
}

final class AuthService: AuthServiceProtocol {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func login(email: String, password: String) -> Single<String> {
        return httpClient
            .request(APIEndpoints.login(email: email, password: password))
            // .request<TokenOnlyResponse>(…) if HTTPClient is generic
            // .map { $0.token } to extract the String
            .map { (token: LoginResponse) in token.token }
    }

    func logout() -> Single<Void> {
         // Expecting server returns 200 OK with maybe empty body
         // We'll decode to EmptyResponse (an empty struct) then map to Void
         return httpClient
             .request(APIEndpoints.logout)
             .map { (_: EmptyResponse) in () }
     }

    // MARK: - Register new account
    func register(email: String, password: String, name: String, age: Int, gender: String) -> Single<Void> {
        return httpClient
            .requestVoid(APIEndpoints.register(email: email, password: password, name: name, age: age, gender: gender))
    }

    func verify(code: String) -> Single<Void> {
        return httpClient
            .requestVoid(APIEndpoints.verify(code: code))
     }
 }

 // MARK: - EmptyResponse
 /// An empty decodable struct for endpoints that return no useful JSON body
 private struct EmptyResponse: Decodable {}

