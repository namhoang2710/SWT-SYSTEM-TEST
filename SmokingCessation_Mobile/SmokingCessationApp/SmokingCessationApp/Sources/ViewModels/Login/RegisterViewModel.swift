import Foundation
import RxSwift
import RxCocoa

/// ViewModel responsible for handling registration logic.
final class RegisterViewModel {
    // MARK: – Inputs
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let confirmPassword = BehaviorRelay<String>(value: "")
    let name = BehaviorRelay<String>(value: "")
    let age = BehaviorRelay<String>(value: "")
    let gender = BehaviorRelay<String>(value: "")
    let registerTapped = PublishRelay<Void>()

    // MARK: – Outputs
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    let registerSuccess = PublishRelay<Void>()

    private let disposeBag = DisposeBag()
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
        bind()
    }

    private func bind() {
        registerTapped
            .withLatestFrom(Observable.combineLatest(email, password, confirmPassword, name, age, gender))
            .flatMapLatest { [unowned self] (email, pwd, confirm, name, ageStr, gender) -> Observable<Void> in
                // Simple client‐side validation
                // 1. Empty-field checks
                guard !email.isEmpty else {
                    self.errorMessage.accept("Email không được để trống")
                    return .empty()
                }
                guard !name.isEmpty else {
                    self.errorMessage.accept("Tên không được để trống")
                    return .empty()
                }
                guard !pwd.isEmpty else {
                    self.errorMessage.accept("Mật khẩu không được để trống")
                    return .empty()
                }

                // 2. Age parsing
                guard let age = Int(ageStr) else {
                    self.errorMessage.accept("Năm sinh không hợp lệ")
                    return .empty()
                }

                // 3. Password confirmation
                guard pwd == confirm else {
                    self.errorMessage.accept("Mật khẩu không khớp")
                    return .empty()
                }
                // If you reach here, all fields are valid:

                return self.authService
                    .register(email: email, password: pwd, name: name, age: age, gender: gender)
                    .asObservable()
                    .do(onNext: { [weak self] _ in self?.isLoading.accept(true) })
                    .catch { error in
                        self.isLoading.accept(false)
                        if let serverError = error as? ServerError {
                            self.errorMessage.accept(serverError.errorMessage)
                        } else {
                            self.errorMessage.accept(error.localizedDescription)
                        }
                        print(age)
                        return .empty()
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.isLoading.accept(false)
                self?.registerSuccess.accept(())
            })
            .disposed(by: disposeBag)
    }
} 
