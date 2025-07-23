//
//  ProfileViewModel.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileViewModel {
    let logoutTapped = PublishRelay<Void>()
    let loadTrigger = PublishRelay<Void>()
    // MARK: - Outputs
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    let logoutSuccess = PublishRelay<Void>()
    let profile = BehaviorRelay<MemberProfile?>(value: nil)
    
    private let disposeBag = DisposeBag()
    private let authService: AuthServiceProtocol
    private let memberService: MemberServiceProtocol

    init(authService: AuthServiceProtocol, memberService: MemberServiceProtocol) {
        self.authService = authService
        self.memberService = memberService
        bindInputs()
    }
    
    private func bindInputs() {
        // load profile
        loadTrigger
            .do(onNext: { [weak self] _ in self?.isLoading.accept(true) })
            .flatMapLatest { [unowned self] in
                memberService.fetchMyProfile()
                    .asObservable()
                    .catch { [weak self] err in
                        self?.isLoading.accept(false)
                        self?.errorMessage.accept(err.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe(onNext: { [weak self] prof in
                self?.isLoading.accept(false)
                self?.profile.accept(prof)
            })
            .disposed(by: disposeBag)

        logoutTapped
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                self.isLoading.accept(true)
                return self.authService.logout()
                    .asObservable()
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
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isLoading.accept(false)
                self.logoutSuccess.accept(())
                handleLogoutSuccess()
            })
            .disposed(by: disposeBag)
    }
    private func handleLogoutSuccess() {
            // 1. Clear stored token
            UserDefaults.standard.removeObject(forKey: "authToken")

            // 2. Recreate app flow to show login screen
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = scene.delegate as? SceneDelegate,
                  let window = sceneDelegate.window else {
                return
            }

            let container = DIContainer.shared.container
            let appCoordinator = AppCoordinator(window: window,
                                                container: container)
            sceneDelegate.appCoordinator = appCoordinator
            appCoordinator.start()
        }
}
