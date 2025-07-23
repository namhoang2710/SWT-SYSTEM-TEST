import UIKit
import RxSwift
import SnapKit

final class BookingViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: BookingViewModel

    private let listView = TymeXListViewV2()
    private let refreshControl = UIRefreshControl()

    weak var coordinator: BookingCoordinator?

    init(viewModel: BookingViewModel = BookingViewModel(coachService: DIContainer.shared.resolve(CoachServiceProtocol.self)!, packageService: DIContainer.shared.resolve(PackageServiceProtocol.self)!)) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Đặt lịch"
        view.backgroundColor = .systemBackground
        setupList()
        bindViewModel()
        viewModel.loadTrigger.accept(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // refresh each time the view appears
        viewModel.loadTrigger.accept(())
    }

    private func setupList() {
        view.addSubview(listView)
        listView.snp.makeConstraints { $0.edges.equalTo(view) }

        // attach refresh control to the internal tableView
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        listView.getTableView().refreshControl = refreshControl
    }

    private func bindViewModel() {
        viewModel.coaches
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] coaches in
                self?.updateList(with: coaches)
            })
            .disposed(by: disposeBag)

        viewModel.requiresPackage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                let vc = VerificationResultViewController(result: .failure(message: "Bạn chưa mua gói.")) {
                    // Navigate to Packages tab on dismiss
                    if let tab = self?.tabBarController {
                        tab.selectedIndex = 2 // assuming packages tab index 2
                    } else {
                        let pkgVC = PackagesViewController()
                        self?.navigationController?.pushViewController(pkgVC, animated: true)
                    }
                }
                self?.present(vc, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in self?.presentAlert(msg) })
            .disposed(by: disposeBag)

        // stop refresh spinner when data arrives or failure happens
        viewModel.isLoading
            .skip(1) // ignore initial
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                if !loading { self?.refreshControl.endRefreshing() }
            })
            .disposed(by: disposeBag)
    }

    @objc private func refreshPulled() {
        viewModel.loadTrigger.accept(())
    }

    private func presentAlert(_ message: String) {
        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đóng", style: .default))
        present(alert, animated: true)
    }

    private func updateList(with coaches: [CoachProfile]) {
        let items = coaches.map { coach -> TymeXListItemModelV2 in
            let leading = TymeXLeadingContent(
                title: "\(coach.account.email)",
                subTitle1: coach.specialty,
                subTitle2: coach.experience,
                isHighlightTitle: true,
                addOnLabelStatus: .neutral("\(coach.account.yearbirth) tuổi | \(coach.account.gender)"),
                addOnButtonStatus: .secondary(coach.account.name)
            )
            let trailing = TymeXTrailingStatus.disclosure(true)
            return TymeXListItemModelV2(
                leadingStatus: .avatar(
                    TymeXAvatarModel(
                        avatarURL: coach.account.image,
                        iconImage: UIImage(systemName: "person.circle"),
                        showIndicatorDot: coach.account.status == "Active" ? true : false)
                ),
                leadingContent: leading,
                trailingStatus: trailing,
                listType: .standard
            )
        }

        let model = TymeXListModelV2(shouldClearBackgroundColor: true, items: items)
        listView.configuration(with: model)

        listView.didSelectItem = { [weak self] index, model in
            guard let self = self else { return }
            let coachId = coaches[index].coachId
            let coachName = coaches[index].account.name
            let vc = CoachScheduleViewController(coachId: coachId, coachName: coachName)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension BookingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.coaches.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coachCell", for: indexPath)
        let coach = viewModel.coaches.value[indexPath.row]
        cell.textLabel?.text = "\(coach.account.name) – \(coach.specialty)"
        return cell
    }
} 
