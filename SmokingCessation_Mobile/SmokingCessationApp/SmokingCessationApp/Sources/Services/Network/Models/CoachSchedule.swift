import Foundation

struct CoachSchedule: Decodable {
    let id: Int
    let startTime: String
    let endTime: String
    let booked: Bool
} 