//
//  ProfileViewController.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie
import SnapKit

final class ProfileViewController: UIViewController, TymeXLoadingViewable {
    var viewModel: ProfileViewModel
    private let logoutButton = SecondaryButton()
    private let avatarView = TymeXAvatar(model: nil)
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let startDateLabel = UILabel()
    private let motivationLabel = UILabel()

    // badges
    private let badgeStack = UIStackView()
    private let statusBadge = PaddedLabel()
    private let genderBadge = PaddedLabel()
    private let consultBadge = PaddedLabel()
    private let checkupBadge = PaddedLabel()

    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let refreshControl = UIRefreshControl()
    
    init(viewModel: ProfileViewModel =
        .init(authService: DIContainer.shared.resolve(AuthServiceProtocol.self)!, memberService: DIContainer.shared.resolve(MemberServiceProtocol.self)!)) {
            
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadTrigger.accept(())
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground

        nameLabel.font = .preferredFont(forTextStyle: .title2)
        emailLabel.font = .preferredFont(forTextStyle: .subheadline)
        emailLabel.textColor = .secondaryLabel
        startDateLabel.font = .preferredFont(forTextStyle: .subheadline)
        motivationLabel.font = .preferredFont(forTextStyle: .body)
        motivationLabel.numberOfLines = 0

        logoutButton.setTitle(with: .trailingIcon(.icLogoutInverse.withTintColor(.red), "Đăng xuất"), textColor: .red)

        badgeStack.axis = .horizontal
        badgeStack.spacing = 8
        badgeStack.alignment = .center
        [statusBadge, genderBadge, consultBadge, checkupBadge].forEach { lbl in
            lbl.font = .preferredFont(forTextStyle: .caption2)
            lbl.textColor = .label
            lbl.layer.cornerRadius = 8
            lbl.clipsToBounds = true
            lbl.setContentHuggingPriority(.required, for: .horizontal)
            badgeStack.addArrangedSubview(lbl)
        }

        let stack = UIStackView(arrangedSubviews: [avatarView, nameLabel, emailLabel, badgeStack, startDateLabel, motivationLabel, logoutButton])
        stack.axis = .vertical; stack.spacing = 12; stack.alignment = .center

        scrollView.addSubview(stack)
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints { $0.edges.equalTo(view) }
        stack.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(20)
            make.leading.trailing.equalTo(view).inset(24)
            make.bottom.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(view).offset(-48)
        }

        // refresh
        refreshControl.addTarget(self, action: #selector(pulledToRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl

        logoutButton.snp.makeConstraints { $0.height.equalTo(45) }
    }
    
    private func bindViewModel() {
        logoutButton.rx.tap
            .bind(to: viewModel.logoutTapped)
            .disposed(by: disposeBag)
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let self = self else { return }
                self.logoutButton.setShowLoadingForTouchUpInside(!loading)
                if !loading { self.refreshControl.endRefreshing() }
            })
            .disposed(by: disposeBag)
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.logoutButton.hideLoading()
                guard let self = self else { return }
                showToastMessage(message: message, subTitle: "Đăng xuất thất bại", icon: .icError.withTintColor(.red), direction: .top)
            })
            .disposed(by: disposeBag)
        viewModel.logoutSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                showToastMessage(message: "Đăng xuất thành công", subTitle: "Bạn đã đăng xuất thành công", icon: SmokingCessation().iconCheckCircle?.withTintColor(.green), direction: .top)
            })
            .disposed(by: disposeBag)

        viewModel.profile
//            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] maybeProfile in
                guard let self = self,
                      let prof = maybeProfile else {
                    return
                }
                nameLabel.text = "\(prof.account.name) (\(prof.account.yearbirth))"
                emailLabel.text = prof.account.email
                startDateLabel.text = "Bắt đầu: \(prof.startDate)"
                motivationLabel.text = "Động lực: \(prof.motivation)"
                let avatarModel = TymeXAvatarModel(avatarURL: prof.account.image, accountName: String(prof.account.name.prefix(2)), showIndicatorDot: true, avatarSize: .sizeXL)
                avatarView.configure(with: avatarModel)
                // badges
                statusBadge.text = prof.account.status
                statusBadge.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)

                genderBadge.text = prof.account.gender
                genderBadge.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)

                consultBadge.text = "Tư vấn: \(prof.account.consultations)"
                consultBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)

                checkupBadge.text = "Khám: \(prof.account.healthCheckups)"
                checkupBadge.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            })
            .disposed(by: disposeBag)
    }

    @objc private func pulledToRefresh() {
        viewModel.loadTrigger.accept(())
    }
}
