import RxSwift

protocol MemberServiceProtocol {
    func fetchMyProfile() -> Single<MemberProfile>
}

final class MemberService: MemberServiceProtocol {
    func fetchMyProfile() -> Single<MemberProfile> {
        HTTPClient.shared.request(APIEndpoints.getMyProfile)
    }
} 