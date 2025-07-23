import Foundation
import RxSwift
import RxCocoa

final class CoachScheduleViewModel {
    // Inputs
    let loadTrigger = PublishRelay<Void>()
    let bookSlotTrigger = PublishRelay<Int>()

    // Outputs
    let schedules = BehaviorRelay<[CoachSchedule]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    let bookingSuccess = PublishRelay<Void>()

    private let disposeBag = DisposeBag()
    private let service: CoachServiceProtocol
    private let coachId: Int

    init(coachId: Int, service: CoachServiceProtocol) {
        self.coachId = coachId
        self.service = service
        bind()
    }

    private func bind() {
        loadTrigger
            .do(onNext: { [weak self] in self?.isLoading.accept(true) })
            .flatMapLatest { [unowned self] _ in
                service.fetchSchedule(coachId: coachId)
                    .asObservable()
                    .catch { [weak self] err in
                        self?.errorMessage.accept(err.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe(onNext: { [weak self] list in
                self?.isLoading.accept(false)
                self?.schedules.accept(list)
            })
            .disposed(by: disposeBag)

        // booking
        bookSlotTrigger
            .do(onNext: { [weak self] _ in self?.isLoading.accept(true) })
            .flatMapLatest { [unowned self] id in
                service.book(slotId: id)
                    .asObservable()
                    .catch { [weak self] err in
                        self?.isLoading.accept(false)
                        self?.errorMessage.accept(err.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe(onNext: { [weak self] in
                self?.isLoading.accept(false)
                self?.bookingSuccess.accept(())
            })
            .disposed(by: disposeBag)
    }
} 