//
//  HTTPClient.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 3/6/25.
//

import Foundation
import Alamofire
import RxSwift

final class HTTPClient {
    static let shared = HTTPClient()
    private let session: Session

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.httpCookieAcceptPolicy = .always
        session = Session(configuration: configuration)
    }

    func request<T: Decodable>(_ convertible: URLRequestConvertible) -> Single<T> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(AFError.explicitlyCancelled))
                return Disposables.create()
            }

            // Build URLRequest so we can log everything
            let urlRequest: URLRequest
            do {
                urlRequest = try convertible.asURLRequest()
            } catch {
                print("❌ Failed to build URLRequest: \(error)")
                single(.failure(error))
                return Disposables.create()
            }

            // 1) Log request
            if let method = urlRequest.method?.rawValue {
                print("➡️ HTTP \(method) \(urlRequest.url?.absoluteString ?? "")")
            }
            if let headers = urlRequest.allHTTPHeaderFields {
                print("   Headers: \(headers)")
            }
            if let body = urlRequest.httpBody,
               let bodyStr = String(data: body, encoding: .utf8) {
                print("   Body: \(bodyStr)")
            }

            // 2) Fire off the request
            let afRequest = self.session.request(urlRequest)

            // 3) Intercept raw DataResponse so we can see raw JSON
            let dataRequest = afRequest
                .validate(statusCode: 200..<300)
                .responseData { response in
                    debugPrint("◀️ Response: \(response)")
                    // Inside your .responseData { response in … } closure:

                    switch response.result {
                    case .success(let data):
                        // — your existing success decoding …
                        do {
                            let model = try JSONDecoder().decode(T.self, from: data)
                            single(.success(model))
                        } catch {
                            print("❌ Decoding error: \(error)")
                            single(.failure(error))
                        }

                    case .failure(let afError):
                        // 1) Pull the raw Data (fallback to empty if nil)
                        let rawData = response.data ?? Data()
                        if let rawString = String(data: rawData, encoding: .utf8) {
                            print("◀️ Error payload: \(rawString)")
                        }

                        // 2) Attempt ServerError
                        if let serverErr = try? JSONDecoder().decode(ServerError.self, from: rawData) {
                            print("❌ ServerError: \(serverErr.errorMessage)")
                            single(.failure(serverErr))

                        // 3) Field‐validation map [String:String]
                        } else if
                            let json = try? JSONSerialization.jsonObject(with: rawData, options: []),
                            let dict = json as? [String: Any]
                        {
                            let fieldMessages = dict.compactMapValues { $0 as? String }
                            if !fieldMessages.isEmpty {
                                let combined = fieldMessages.values
                                    .map { "• \($0)" }
                                    .joined(separator: "\n")
                                let validationError = NSError(
                                    domain: "",
                                    code: -2,
                                    userInfo: [NSLocalizedDescriptionKey: combined]
                                )
                                single(.failure(validationError))

                            // 4) Common single‐message keys
                            } else if let msg = dict["message"] as? String ?? dict["error"] as? String {
                                let fallbackError = NSError(
                                    domain: "",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: msg]
                                )
                                single(.failure(fallbackError))

                            // 5) Last‐ditch generic
                            } else {
                                let generic = NSError(
                                    domain: "",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey:
                                        "Đã xảy ra lỗi không xác định.\n\(String(data: rawData, encoding: .utf8) ?? "")"
                                    ]
                                )
                                single(.failure(generic))
                            }

                        // 6) If no JSON at all, just bubble AFError
                        } else {
                            single(.failure(afError))
                        }
                    }

                }

            return Disposables.create {
                dataRequest.cancel()
            }
        }
    }

    // MARK: - For endpoints that return 2xx with non-JSON/plain-text body
    /// Makes a request but ignores the response body – only the HTTP status code is validated.
    /// Emits `Void` on any 2xx response, or an error otherwise.
    func requestVoid(_ convertible: URLRequestConvertible) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(AFError.explicitlyCancelled))
                return Disposables.create()
            }

            let urlRequest: URLRequest
            do { urlRequest = try convertible.asURLRequest() }
            catch { single(.failure(error)); return Disposables.create() }

            // Log request as in main request()
            if let method = urlRequest.method?.rawValue {
                print("➡️ HTTP \(method) \(urlRequest.url?.absoluteString ?? "")")
            }
            if let headers = urlRequest.allHTTPHeaderFields {
                print("   Headers: \(headers)")
            }

            let request = self.session.request(urlRequest)
                .validate(statusCode: 200..<300)
                .response { response in
                    if let status = response.response?.statusCode {
                        print("◀️ Status: \(status)")
                    }
                    if let data = response.data, let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
                        print("◀️ Body: \(raw)")
                    }

                    switch response.result {
                    case .success:
                        single(.success(()))
                    case .failure(let afError):
                        // 1) Pull the raw Data (fallback to empty if nil)
                        let rawData = response.data ?? Data()
                        if let rawString = String(data: rawData, encoding: .utf8) {
                            print("◀️ Error payload: \(rawString)")
                        }

                        // 2) Attempt ServerError
                        if let serverErr = try? JSONDecoder().decode(ServerError.self, from: rawData) {
                            print("❌ ServerError: \(serverErr.errorMessage)")
                            single(.failure(serverErr))

                        // 3) Field‐validation map [String:String]
                        } else if
                            let json = try? JSONSerialization.jsonObject(with: rawData, options: []),
                            let dict = json as? [String: Any]
                        {
                            let fieldMessages = dict.compactMapValues { $0 as? String }
                            if !fieldMessages.isEmpty {
                                let combined = fieldMessages.values
                                    .map { "• \($0)" }
                                    .joined(separator: "\n")
                                let validationError = NSError(
                                    domain: "",
                                    code: -2,
                                    userInfo: [NSLocalizedDescriptionKey: combined]
                                )
                                single(.failure(validationError))

                            // 4) Common single‐message keys
                            } else if let msg = dict["message"] as? String ?? dict["error"] as? String {
                                let fallbackError = NSError(
                                    domain: "",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: msg]
                                )
                                single(.failure(fallbackError))

                            // 5) Last‐ditch generic
                            } else {
                                let generic = NSError(
                                    domain: "",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey:
                                        "Đã xảy ra lỗi không xác định.\n\(String(data: rawData, encoding: .utf8) ?? "")"
                                    ]
                                )
                                single(.failure(generic))
                            }

                        // 6) If no JSON at all, just bubble AFError
                        } else {
                            single(.failure(afError))
                        }
                    }
                }

            return Disposables.create { request.cancel() }
        }
    }
}

