//
//  LoginViewController.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 3/6/25.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie
import SnapKit

final class LoginViewController: UIViewController {
    // MARK: – Dependencies
    var viewModel: LoginViewModel!
    weak var coordinator: LoginCoordinator?

    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = PrimaryButton()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let disposeBag = DisposeBag()
    private let loginAnimationView: LottieAnimationView = {
        let anim = LottieAnimationView(name: SmokingCessation.noSmoking)
               anim.contentMode = .scaleAspectFit
               anim.loopMode = .loop
               return anim
    }()
    private let separatorView = UIView()
    private let registerLinkLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        loginAnimationView.play()
    }

    private func setupUI() {
        view.backgroundColor = .white
        emailField.placeholder = "Nhập email của bạn"
        emailField.autocapitalizationType = .none
        emailField.borderStyle = .roundedRect
        emailField.textColor = .accent
        passwordField.placeholder = "Mật khẩu"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.textColor = .accent
        loginButton.setTitle(with: .trailingIcon(.icRequestSentInverse, "Đăng nhập"))
        [loginAnimationView, emailField, passwordField, loginButton].forEach {
            view.addSubview($0)
        }

        // Add separator and link
        [separatorView, registerLinkLabel].forEach { view.addSubview($0) }

        separatorView.backgroundColor = .lightGray.withAlphaComponent(0.6)
        registerLinkLabel.isUserInteractionEnabled = true
        let registrAttr = NSAttributedString(string: "Đăng ký tài khoản", attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.accent
        ])
        registerLinkLabel.attributedText = registrAttr

        // MARK: - Setup layout SNP
        loginAnimationView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalTo(view)
            make.width.height.equalTo(200)
        }
        
        emailField.snp.makeConstraints { make in
            make.top.equalTo(loginAnimationView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(40)
        }
    
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(20)
            make.leading.trailing.equalTo(emailField)
            make.height.equalTo(40)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(25)
            make.centerX.equalTo(view)
            make.height.equalTo(45)
            make.leading.trailing.equalToSuperview().inset(60)
        }

        // Separator constraints
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view).inset(40)
            make.height.equalTo(1)
        }

        registerLinkLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(12)
            make.centerX.equalTo(view)
        }

        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapRegister))
        registerLinkLabel.addGestureRecognizer(tap)
    }

    @objc private func didTapRegister() {
        let regVM = DIContainer.shared.resolve(RegisterViewModel.self)!
        let regVC = RegisterViewController(viewModel: regVM)
        navigationController?.pushViewController(regVC, animated: true)
    }

    private func bindViewModel() {
        // 1) Two‐way bind text ↔ VM
        emailField.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)

        passwordField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)

        // 2) Login tap → VM
        loginButton.rx.tap
            .bind(to: viewModel.loginTapped)
            .disposed(by: disposeBag)

        // 3) Show/hide spinner & disable button
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let self = self else { return }
                self.loginButton.setShowLoadingForTouchUpInside(!loading)
            })
            .disposed(by: disposeBag)

        // 4) Show error alert
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.loginButton.hideLoading()
                guard let self = self else { return }
                showToastMessage(message: message, subTitle: "Đăng nhập thất bại", icon: .icError.withTintColor(.red))
//                let alert = UIAlertController(title: "Login Failed",
//                                              message: message,
//                                              preferredStyle: .alert)
//                alert.addAction(.init(title: "OK", style: .default))
//                self.present(alert, animated: true)
            })
            .disposed(by: disposeBag)

        // 5) On success → call coordinator
        viewModel.loginSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                print("🔔 loginSuccess triggered in VC, calling coordinator...")
                self?.coordinator?.didLoginSuccessfully()
                self?.showToastMessage(message: "Đăng nhập thành công", icon: .icCheckCircle.withTintColor(.green), direction: .top)
            })
            .disposed(by: disposeBag)
    }
}


