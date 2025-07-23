//
//  PackagesViewModel.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import RxSwift
import RxCocoa

/// Exposed data for each card
struct PackageCard {
  let id: Int
  let title: String
  let subtitle: String
  let description: String
  let numberDetails: String
  let isBestValue: Bool
  let price: Decimal
  let isSelected: BehaviorRelay<Bool>
}

final class PackagesViewModel {
    // MARK: – Inputs
    /// Trigger loading (e.g. in viewDidLoad)
    let loadTrigger = PublishRelay<Void>()
    /// User tapped a card at index
    let selectTrigger = PublishRelay<Int>()
    /// Trigger buy package when a package bought successfully
    let buyCardTrigger = PublishRelay<Void>()
    
    // MARK: – Outputs
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    let cards = BehaviorRelay<[PackageCard]>(value: [])
    var selectedPackage = PublishRelay<PackageCard>()
    var buyPackageResponse = PublishRelay<BuyPackageResponse>()
    
    private let disposeBag = DisposeBag()
    private let service: PackageServiceProtocol
    
    init(service: PackageServiceProtocol) {
        self.service = service
        bind()
    }
    
    private func bind() {
        // 1) Load packages when triggered
        loadTrigger
            .do(onNext: { [weak self] in self?.isLoading.accept(true) })
            .flatMapLatest { [unowned self] in
                service.fetchAll()
                    .asObservable()
                    .catch { error in
                        self.isLoading.accept(false)
                        self.errorMessage.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] packages in
                guard let self = self, !packages.isEmpty else {
                    self?.isLoading.accept(false)
                    return
                }
                
                // Find best‐value price
                let maxPrice = packages.map(\.price).max() ?? 0
                
                // Map into PackageCard
                let newCards = packages.map { pkg -> PackageCard in
                    let subtitle = "\(pkg.price)₫ • \(pkg.duration) ngày"
                    let numberDetails = "\(pkg.numberOfConsultations) tư vấn & \(pkg.numberOfHealthCheckups) lần kiểm tra SK"
                    return PackageCard(
                        id: pkg.id,
                        title: pkg.name,
                        subtitle: subtitle,
                        description: pkg.description, numberDetails: numberDetails,
                        isBestValue: pkg.price == maxPrice, price:pkg.price,
                        isSelected: BehaviorRelay(value: false)
                    )
                }
                
                self.cards.accept(newCards)
                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
        
        // 2) Handle selection taps
        selectTrigger
            .withLatestFrom(cards) {
                index, cards in (index, cards)
            }
            .subscribe(onNext: { [weak self] index, cards in
                cards.enumerated().forEach { i, card in
                    card.isSelected.accept(i == index)
                }
                self?.selectedPackage.accept(cards[index])
            })
            .disposed(by: disposeBag)
        // 3) Buy card
        buyCardTrigger
            .do(onNext: { [weak self] in
                self?.isLoading.accept(true)
            })
            .withLatestFrom(selectedPackage)
            .flatMapLatest { [unowned self] package -> Observable<BuyPackageResponse> in
                // Call the API to buy a package
                service.buyPackage(id: package.id)
                    .asObservable()
                    .catch { [weak self] error in
                        // Handle the error & forward to UI layer
                        self?.isLoading.accept(false)
                        if let serverError = error as? ServerError {
                            self?.errorMessage.accept(serverError.errorMessage)
                        } else {
                            self?.errorMessage.accept(error.localizedDescription)
                        }
                        // Return an empty sequence so the stream completes gracefully
                        return Observable<BuyPackageResponse>.empty()
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] packageResponse in
                guard let self = self else { return }
                // Stop loading and propagate the response
                self.isLoading.accept(false)
                self.buyPackageResponse.accept(packageResponse)
            })
            .disposed(by: disposeBag)
    }
}

