import Foundation
import RxSwift
import RxCocoa

final class BookingViewModel {
    // Inputs
    let loadTrigger = PublishRelay<Void>()

    // Outputs
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    let coaches = BehaviorRelay<[CoachProfile]>(value: [])
    let requiresPackage = PublishRelay<Void>()

    private let disposeBag = DisposeBag()
    private let coachService: CoachServiceProtocol
    private let packageService: PackageServiceProtocol

    init(coachService: CoachServiceProtocol, packageService: PackageServiceProtocol) {
        self.coachService = coachService
        self.packageService = packageService
        bind()
    }

    private func bind() {
        loadTrigger
            .do(onNext: { [weak self] in self?.isLoading.accept(true) })
            .flatMapLatest { [unowned self] _ in
                packageService.fetchPurchased()
                    .asObservable()
                    .catch { [weak self] err in
                        self?.errorMessage.accept(err.localizedDescription)
                        return .empty()
                    }
            }
            .flatMapLatest { [unowned self] resp -> Observable<[CoachProfile]> in
                if resp.purchasedPackages.isEmpty {
                    self.requiresPackage.accept(())
                    self.isLoading.accept(false)
                    return .empty()
                }
                return coachService.fetchAll().asObservable()
            }
            .subscribe(onNext: { [weak self] list in
                self?.isLoading.accept(false)
                self?.coaches.accept(list)
            })
            .disposed(by: disposeBag)
    }
} 