import Foundation

struct SmokingLog: Decodable {
    let id: Int
    let memberId: Int
    let date: String
    let cigarettes: Int
    let cost: Double
    let healthStatus: String
    let cravingLevel: Int
    let notes: String
} 