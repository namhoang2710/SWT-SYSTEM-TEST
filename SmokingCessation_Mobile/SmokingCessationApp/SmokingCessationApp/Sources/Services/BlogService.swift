//
//  BlogServices.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 27/6/25.
//

import Foundation
import RxSwift

protocol BlogServiceProtocol {
    func fetchAll() -> Single<[Blog]>
    func toggleLike(blogId: Int) -> Single<BlogLikeResponse>
    func fetchComments(blogId: Int) -> Single<[Comment]>
    func createComment(blogId: Int, content: String) -> Single<Void>
}

final class BlogService: BlogServiceProtocol {
    func fetchAll() -> Single<[Blog]> {
        HTTPClient.shared.request(APIEndpoints.getAllBlogs)
    }
    func toggleLike(blogId: Int) -> Single<BlogLikeResponse> {
        HTTPClient.shared.request(APIEndpoints.toggleLike(blogId: blogId))
    }
    func fetchComments(blogId: Int) -> Single<[Comment]> {
        HTTPClient.shared.request(APIEndpoints.getComments(blogId: blogId))
    }
    func createComment(blogId: Int, content: String) -> Single<Void> {
        HTTPClient.shared.requestVoid(APIEndpoints.createComment(blogId: blogId, content: content))
    }
}
