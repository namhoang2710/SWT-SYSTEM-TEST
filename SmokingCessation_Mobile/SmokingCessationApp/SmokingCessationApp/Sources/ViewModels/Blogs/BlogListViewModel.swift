//
//  BlogListViewModel.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 27/6/25.
//

import Foundation
import RxRelay
import RxSwift

final class BlogListViewModel {
    let loadTrigger = PublishRelay<Void>()

    let blogs = BehaviorRelay<[Blog]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<String>()

    private let service: BlogServiceProtocol
    private let disposeBag = DisposeBag()

    init(service: BlogServiceProtocol) {
        self.service = service
        bind()
    }

    private func bind() {
        loadTrigger
            .do { [weak self] _ in self?.isLoading.accept(true) }
            .flatMapLatest { [unowned self] in
                service.fetchAll()
                    .asObservable()
                    .catch { [weak self] err in
                        self?.error.accept(err.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe(onNext: { [weak self] list in
                self?.isLoading.accept(false)
                self?.blogs.accept(list)
            })
            .disposed(by: disposeBag)
    }
}
