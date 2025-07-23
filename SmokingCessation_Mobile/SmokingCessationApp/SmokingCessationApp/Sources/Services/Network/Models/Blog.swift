//
//  Blog.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 27/6/25.
//


struct Blog: Decodable {
    let blogID: Int
    let account: CoachAccount        // reuse existing struct
    let title: String
    let content: String
    let createdDate: String
    let createdTime: String
    let image: String?
    var likes: Int
}
