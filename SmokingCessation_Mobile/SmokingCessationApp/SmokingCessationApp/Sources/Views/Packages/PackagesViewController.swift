//
//  PackagesViewController.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import UIKit
import RxSwift
import StripePaymentSheet

final class PackagesViewController: UIViewController, TymeXLoadingViewable {
    private var selectedPackage: PackageCard?
    private let viewModel: PackagesViewModel
    private let disposeBag = DisposeBag()
    private let checkoutButton = PrimaryButton()
    /// STRIPE  Payment
    var paymentSheet: PaymentSheet?
    private let stackView: UIStackView = {
      let sv = UIStackView(); sv.axis = .vertical; sv.spacing = 16
      sv.translatesAutoresizingMaskIntoConstraints = false
      return sv
    }()

    weak var coordinator: PackagesCoordinator?
    // Keep references so we can bind selection state
    private var cardViews: [SelectionCard] = []
    private let smokingLogButton = PrimaryButton()
    private var purchasedPackages: [PurchasedPackage] = []
    private var purchasedTableView: UITableView?

    init(viewModel: PackagesViewModel =
         .init(service: DIContainer.shared.resolve(PackageServiceProtocol.self)!)) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gói dịch vụ"
        checkoutButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)

        // First: check purchased packages
        fetchPurchasedPackages()

        setupLayout()
        bindViewModel()
        viewModel.loadTrigger.accept(())    // kick off load
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPurchasedPackages()
    }
    
    private func setupLayout() {
        checkoutButton.setTitle(with: .trailingIcon(.icCardPaymentInverse, "Thanh toán"), textColor: .white)
        [stackView, checkoutButton].forEach {
            view.addSubview($0)
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalTo(view).inset(16)
        }
        checkoutButton.snp.makeConstraints { make in
            make.height.equalTo(45)
            make.top.equalTo(stackView.snp.bottom).offset(25)
            make.centerX.equalTo(view)
            make.leading.trailing.equalTo(view).inset(16)
        }
    }
    
    private func bindViewModel() {
        // 1) When we get the full list of cards, build UI
        viewModel.cards
          .observe(on: MainScheduler.instance)
          .subscribe(onNext: { [weak self] cards in
            self?.renderCards(cards)
          })
          .disposed(by: disposeBag)

        // 2) Also re-render *entire* list every time the user selects one:
        viewModel.selectTrigger
          .withLatestFrom(viewModel.cards) { _, cards in cards }
          .observe(on: MainScheduler.instance)
          .subscribe(onNext: { [weak self] cards in
            self?.renderCards(cards)
          })
          .disposed(by: disposeBag)

        // (You can still react to selectedPackage for side-effects)
        viewModel.selectedPackage
          .subscribe(onNext: { pkg in
            self.selectedPackage = pkg
              self.checkoutButton.showLoading {
              }
              self.checkoutButton.isEnabled = false
            self.setupPagementGate()
            print("User picked package id:", pkg.id)
          })
          .disposed(by: disposeBag)

        // 3) Listen for successful purchase response
        viewModel.buyPackageResponse
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self, let pkg = self.selectedPackage else { return }
                self.coordinator?.showSuccessScreen(buyPackageResponse: response, package: pkg)
            })
            .disposed(by: disposeBag)
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let self = self else { return }
                if loading {
                    mxShowFullScreenLoadingView(
                        duration: 0,
                        lottieAnimationName: SmokingCessation.loadingAnimation,
                        bundle: BundleSmokingCessation.bundle
                    )
                } else {
                    tymeXHideLoadingView()
                }
            })
            .disposed(by: disposeBag)
      }

      private func renderCards(_ cards: [PackageCard]) {
        // clear out what's there
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()

        // rebuild everything
        for (i, cardData) in cards.enumerated() {
          let subTitleLabel = UILabel()
          subTitleLabel.attributedText = NSAttributedString(
            string: cardData.description,
            attributes: SmokingCessation.textBodyDefaultM.color(.gray)
          )

          let subTitle2Label = UILabel()
          subTitle2Label.attributedText = NSAttributedString(
            string: cardData.subtitle,
            attributes: SmokingCessation.textBodyEmphasizeM.color(.green)
          )

          let model = SelectionCardModel(
            highlightLabel: cardData.isBestValue ? "Có giá trị nhất" : nil,
            cardState: cardData.isSelected.value ? .selected : .normal,
            topSlotOption: .predefined(
              PredefinedSlot(
                title: cardData.title,
                badge: cardData.numberDetails,
                subTitle1: subTitleLabel,
                subTitle2: subTitle2Label
              )
            ),
            propertyID: "\(cardData.id)"
          )

          let card = SelectionCard(model: model)

          // bind selection state
          cardData.isSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isSel in
              card.model.cardState = isSel ? .selected : .normal
            })
            .disposed(by: disposeBag)

          // on tap, tell VM which index—and because of our selectTrigger subscription,
          // that will *also* call renderCards again
          card.onStateChanged = { _ in
            self.viewModel.selectTrigger.accept(i)
          }

          cardViews.append(card)
          stackView.addArrangedSubview(card)
        }
      }
    
    // MARK: - Stripe payment sheet
    private func setupPagementGate() {
        print("setup payment sheet called")
        // MARK: Fetch the PaymentIntent client secret, Ephemeral Key secret, Customer ID, and publishable key
        guard let pkg = selectedPackage else {
            // if you're using Toast-Swift (or similar) in your project:
            showToastMessage(message: "Hãy chọn gói", icon: .icError.withTintColor(.black), direction: .top)
            return
          }
        let checkoutUrlString =
                "https://smoking-cessation.onrender.com/api/payment/sheet?amount=\(pkg.price)&currency=VND"
        var request = URLRequest(url: URL(string: checkoutUrlString)!)
        request.httpMethod = "POST"
        let token = UserDefaults.standard.string(forKey: "authToken")
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        print(request.headers)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
          guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
                let paymentIntentClientSecret = json["paymentIntent"] as? String,
                let publishableKey = json["publishableKey"] as? String,
                let customerId = json["customer"] as? String,
                let self = self else {
            return
          }
        print(request)
          STPAPIClient.shared.publishableKey = publishableKey
          // MARK: Create a PaymentSheet instance
          var configuration = PaymentSheet.Configuration()
          configuration.merchantDisplayName = "Example, Inc."
          configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
          // Set `allowsDelayedPaymentMethods` to true if your business handles
          // delayed notification payment methods like US bank accounts.
          configuration.allowsDelayedPaymentMethods = true
          self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)

          DispatchQueue.main.async {
            self.checkoutButton.isEnabled = true
            self.checkoutButton.hideLoading()
          }
        })
        task.resume()
    }
    
    @objc
    func didTapCheckoutButton() {
      // MARK: Start the checkout process
      paymentSheet?.present(from: self) { paymentResult in
        // MARK: Handle the payment result
        switch paymentResult {
        case .completed:
            self.showToastMessage(message: "Thanh Toán thành công", icon: .icCheck.withTintColor(.green), direction: .top)
            self.viewModel.buyCardTrigger.accept(())
        case .canceled:
            self.showToastMessage(message: "Đã huỷ thanh toán", icon: .icWarning.withTintColor(.yellow), direction: .top)
        case .failed(let error):
            self.showToastMessage(message: "Giao dịch thất bại",subTitle: error.localizedDescription, icon: .icWarning.withTintColor(.yellow), direction: .top)
        }
      }
        checkoutButton.hideLoading()
    }

    // MARK: - Purchased packages flow
    private func fetchPurchasedPackages() {
        viewModel.isLoading.accept(true)
        DIContainer.shared.resolve(PackageServiceProtocol.self)!
            .fetchPurchased()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                self.viewModel.isLoading.accept(false)
                // stop refresh if any
                self.purchasedTableView?.refreshControl?.endRefreshing()
                if response.purchasedPackages.isEmpty {
                    // show selection UI
                    self.setupLayout()
                    self.bindViewModel()
                    self.viewModel.loadTrigger.accept(())
                } else {
                    self.purchasedPackages = response.purchasedPackages
                    self.renderPurchasedList()
                }
            }, onFailure: { [weak self] err in
                self?.viewModel.isLoading.accept(false)
                self?.purchasedTableView?.refreshControl?.endRefreshing()
                self?.showToastMessage(message: err.localizedDescription, icon: .icError.withTintColor(.red), direction: .top)
            })
            .disposed(by: disposeBag)
    }

    private func renderPurchasedList() {
        // Clear
        view.subviews.forEach { $0.removeFromSuperview() }

        let tableView = UITableView()
        self.purchasedTableView = tableView
        tableView.register(PurchasedPackageCell.self, forCellReuseIdentifier: "pkgCell")
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        // Pull to refresh
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshPurchasedList), for: .valueChanged)
        tableView.refreshControl = refresh

        // Header
        let headerLabel = UILabel()
        headerLabel.text = "Gói đã mua của bạn"
        headerLabel.font = .preferredFont(forTextStyle: .extraLargeTitle2)
        headerLabel.textAlignment = .center
        headerLabel.textColor = .accent
        headerLabel.numberOfLines = 0
        headerLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        tableView.tableHeaderView = headerLabel

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
        ])

        // Smoking log button
        smokingLogButton.setTitle(with: .text("Ghi nhật ký hút thuốc"))
        smokingLogButton.setShowLoadingForTouchUpInside(false)
        view.addSubview(smokingLogButton)
        smokingLogButton.snp.makeConstraints { make in
            make.height.equalTo(45)
            make.leading.trailing.equalTo(view).inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        smokingLogButton.addTarget(self, action: #selector(openSmokingLog), for: .touchUpInside)

        // reload data
        tableView.reloadData()
    }

    @objc private func openSmokingLog() {
        let logVC = SmokingLogViewController()
        navigationController?.pushViewController(logVC, animated: true)
    }

    @objc private func refreshPurchasedList() {
        fetchPurchasedPackages()
    }
}

// MARK: - UITableViewDataSource
extension PackagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchasedPackages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pkgCell", for: indexPath) as! PurchasedPackageCell
        cell.configure(with: purchasedPackages[indexPath.row])
        return cell
    }
}

