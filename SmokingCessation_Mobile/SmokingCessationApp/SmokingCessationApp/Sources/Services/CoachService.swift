import RxSwift

protocol CoachServiceProtocol {
    func fetchAll() -> Single<[CoachProfile]>
    func fetchSchedule(coachId: Int) -> Single<[CoachSchedule]>
    func book(slotId: Int) -> Single<Void>
}

final class CoachService: CoachServiceProtocol {
    func fetchAll() -> Single<[CoachProfile]> {
        return HTTPClient.shared.request(APIEndpoints.getAllCoachProfiles)
    }

    func fetchSchedule(coachId: Int) -> Single<[CoachSchedule]> {
        return HTTPClient.shared.request(APIEndpoints.getCoachSchedule(coachId: coachId))
    }

    func book(slotId: Int) -> Single<Void> {
        return HTTPClient.shared.requestVoid(APIEndpoints.bookSlot(slotId: slotId))
    }
} 