//
//  APIEndpoints.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 3/6/25.
//

import Foundation
import Alamofire

/// A centralized place to pick your environment's root URL.
/// If you ever need to point at staging vs. production, just swap this one constant.
enum BaseAPI {
    // Replace with your real production base URL:
    static let baseURL = URL(string: "https://smoking-cessation.onrender.com")!
}

/// All of your API routes in one place.
/// Conforms to `URLRequestConvertible` so `HTTPClient` can send these directly.
enum APIEndpoints: URLRequestConvertible {
    // authentication
    case login(email: String, password: String)
    case register(email: String, password: String, name: String, age: Int, gender: String)
    case logout
    // Packages
    case getAllPackages
    case buyPackage(id: Int)
    case getPurchasedPackages
    // Smoking log
    case createSmokingLog(body: [String: Any])
    case getSmokingLogs
    // verification
    case verify(code: String)
    // Coach
    case getAllCoachProfiles
    case getCoachSchedule(coachId: Int)
    case bookSlot(slotId: Int)
    // Blogs
    case getAllBlogs
    // Member
    case getMyProfile
    case toggleLike(blogId: Int)
    case getComments(blogId: Int)
    case createComment(blogId: Int, content: String)

    // MARK: – HTTP Method for each endpoint
    var method: HTTPMethod {
        switch self {
        case .login, .register:
            return .post
        case .logout:
            return .post
        case .getAllPackages:
            return .get
        case .buyPackage:
            return .post
        case .getPurchasedPackages:
            return .get
        case .verify:
            return .get
        case .createSmokingLog:
            return .post
        case .getSmokingLogs, .getAllCoachProfiles, .getCoachSchedule:
            return .get
        case .bookSlot:
            return .post
        case .getAllBlogs, .getMyProfile:
            return .get
        case .toggleLike:
            return .put
        case .getComments:
            return .get
        case .createComment:
            return .post
        }
    }
    
    // MARK: - Require authentication token
    private var requiresAuth: Bool {
          switch self {
          case .login, .register, .verify:
              return false
          default:
              return true
          }
      }

    // MARK: – Path (appended to the baseURL)
    var path: String {
        switch self {
        case .login:
            return "/api/account/login"
        case .logout:
            return "/api/account/logout"
        case .register:
            return "/api/account/register"
        case .getAllPackages:
            return "/api/admin/packages/all"
        case .buyPackage(id: let id):
            return "api/packages/buy"
        case .getPurchasedPackages:
            return "/api/packages/list"
        case .verify(let code):
            return "/api/account/verify"
        case .createSmokingLog:
            return "/api/packages/smoking-log"
        case .getSmokingLogs:
            return "/api/packages/smoking-logs/list"
        case .getAllCoachProfiles:
            return "/api/coach/profile/all"
        case .getCoachSchedule(let id):
            return "/api/user/consultation/coach-schedule/\(id)"
        case .bookSlot:
            return "/api/user/consultation/book"
        case .getAllBlogs:
            return "/api/blogs/all"
        case .getMyProfile:
            return "/api/member/profile/me"
        case .toggleLike(let id):
            return "/api/blogs/like/\(id)"
        case .getComments(let id):
            return "/api/comments/\(id)"
        case .createComment(let id, _):
            return "/api/comments/create/\(id)"
        }
    }

    // MARK: – Build the URLRequest
    func asURLRequest() throws -> URLRequest {
        // Start from your single `BaseAPI.baseURL`
        let fullURL = BaseAPI.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: fullURL)
        request.method = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        switch self {
        case .login(let email, let password):
            let body: [String: Any] = [
                "email": email,
                "password": password
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        case .register(let email, let password, let name, let age, let gender):
            let body: [String: Any] = [
                "email": email,
                "password": password,
                "name": name,
                "yearbirth": age,
                "gender": gender
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        case .getAllPackages, .getPurchasedPackages, .getSmokingLogs, .getAllCoachProfiles, .getCoachSchedule: break
        case .logout: break
        case .buyPackage(id: let id):
            request.setValue("\(id)", forHTTPHeaderField: "Package-Id")
        case .createSmokingLog(let body):
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        case .verify(let code):
            var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [URLQueryItem(name: "code", value: code)]
            request.url = urlComponents?.url
        case .bookSlot(let id):
            var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [URLQueryItem(name: "slotId", value: String(id))]
            request.url = urlComponents?.url
        case .getAllBlogs, .getMyProfile: break
        case .toggleLike: break
        case .getComments: break
        case .createComment(_, let content):
            var comps = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            comps?.queryItems = [URLQueryItem(name: "content", value: content)]
            request.url = comps?.url
        }
        // set headers
        if requiresAuth,
                let token = UserDefaults.standard.string(forKey: "authToken"),
                !token.isEmpty {
                 request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
