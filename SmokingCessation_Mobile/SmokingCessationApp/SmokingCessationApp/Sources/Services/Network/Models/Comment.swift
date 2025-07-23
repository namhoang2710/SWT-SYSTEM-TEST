import Foundation

struct Comment: Decodable {
    let commentId: Int
    let accountId: Int
    let content: String
    let commenterName: String
    let commenterImage: String?
    let createdDate: String
    let createdTime: String
} 