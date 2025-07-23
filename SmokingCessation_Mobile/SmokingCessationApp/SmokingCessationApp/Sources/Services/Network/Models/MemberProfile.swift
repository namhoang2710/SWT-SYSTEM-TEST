import Foundation

struct MemberProfile: Decodable {
    let memberId: Int
    let account: CoachAccount // reuse structure
    let startDate: String
    let motivation: String
} 