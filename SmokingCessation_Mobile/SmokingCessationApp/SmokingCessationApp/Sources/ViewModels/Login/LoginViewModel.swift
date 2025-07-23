//
//  LoginViewModel.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 3/6/25.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel {
    // MARK: - Inputs (plain Observables)
    let email       = BehaviorRelay<String>(value: "")
    let password    = BehaviorRelay<String>(value: "")
    let loginTapped = PublishRelay<Void>()

    // MARK: - Outputs (plain Observables / Relays)
    let isLoading    = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    let loginSuccess = PublishRelay<Void>()

    private let disposeBag = DisposeBag()
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
        bindInputs()
    }

    private func bindInputs() {
           loginTapped
               .asObservable()
               .withLatestFrom(Observable.combineLatest(email, password))
               .flatMapLatest { [weak self] email, password -> Observable<String> in
                   guard let self = self else { return .empty() }
                   self.isLoading.accept(true)
                   return self.authService
                       .login(email: email, password: password)  // Single<String>
                       .asObservable()                           // Observable<String>
                       .catch { error in
                           self.isLoading.accept(false)
                           if let serverError = error as? ServerError {
                               self.errorMessage.accept(serverError.errorMessage)
                           } else {
                               self.errorMessage.accept(error.localizedDescription)
                           }
                           return .empty()
                       }
               }
               .observe(on: MainScheduler.instance)
               .subscribe(onNext: { [weak self] token in
                   guard let self = self else { return }
                   self.isLoading.accept(false)
                   // Store your token however you like:
                   UserDefaults.standard.set(token, forKey: "authToken")
                   print("Received auth token: \(token)")
                   self.loginSuccess.accept(())
               })
               .disposed(by: disposeBag)
       }
}

