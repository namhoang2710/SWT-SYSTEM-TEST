import Foundation

struct CoachAccount: Decodable {
    let id: Int
    let email: String
    let name: String
    let yearbirth: Int
    let gender: String
    let role: String
    let status: String
    let image: String?
    let consultations: Int
    let healthCheckups: Int
}

struct CoachProfile: Decodable {
    let coachId: Int
    let account: CoachAccount
    let specialty: String
    let experience: String
} 
