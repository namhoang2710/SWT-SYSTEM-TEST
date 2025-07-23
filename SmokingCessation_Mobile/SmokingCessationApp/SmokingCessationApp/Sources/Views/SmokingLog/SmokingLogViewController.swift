import UIKit
import SnapKit
import RxSwift
import LocalAuthentication

final class SmokingLogViewController: UIViewController {
    // Form fields
    private let dateField = UITextField()
    private let cigarettesSlider = TymeXSlider()
    private let costField = UITextField()
    private let healthStatusField = UITextField()
    private let cravingSlider = TymeXSlider()
    private let notesField = UITextField()
    private let submitButton = PrimaryButton()

    // List
    private let tableView = UITableView()
    private var logs: [SmokingLog] = []
    private let disposeBag = DisposeBag()

    // Biometric blur overlay
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Khai báo nhật ký"
        view.backgroundColor = .systemBackground
        setupFormUI()
        setupTable()
        setupBlur()
        fetchLogs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authenticate()
    }

    private func setupFormUI() {
        let textFields: [UITextField] = [dateField, costField, healthStatusField, notesField]
        let placeholders = ["Ngày (YYYY-MM-DD)", "Chi phí", "Tình trạng sức khoẻ", "Ghi chú"]
        for (field, ph) in zip(textFields, placeholders) {
            field.placeholder = ph
            field.borderStyle = .roundedRect
            view.addSubview(field)
        }

        // labels for sliders
        let cigLabel = UILabel(); cigLabel.text = "Số thuốc lá"; cigLabel.font = .preferredFont(forTextStyle: .footnote)
        let craveLabel = UILabel(); craveLabel.text = "Mức độ thèm thuốc"; craveLabel.font = .preferredFont(forTextStyle: .footnote)

        view.addSubview(cigLabel)
        view.addSubview(craveLabel)

        // configure sliders
        cigarettesSlider.minimumValue = 0
        cigarettesSlider.maximumValue = 40
        cigarettesSlider.numberOfSteps = 0
        cigarettesSlider.indicatorValue = 0
        cigarettesSlider.valueType = .integer

        cravingSlider.minimumValue = 0
        cravingSlider.maximumValue = 10
        cravingSlider.numberOfSteps = 10
        cravingSlider.indicatorValue = 0
        cravingSlider.valueType = .integer

        view.addSubview(cigarettesSlider)
        view.addSubview(cravingSlider)

        submitButton.setTitle(with: .text("Gửi"))
        submitButton.setShowLoadingForTouchUpInside(false)
        view.addSubview(submitButton)

        // Layout
        dateField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalTo(view).inset(24)
            make.height.equalTo(40)
        }

        cigLabel.snp.makeConstraints { make in
            make.top.equalTo(dateField.snp.bottom).offset(16)
            make.leading.trailing.equalTo(dateField)
        }

        cigarettesSlider.snp.makeConstraints { make in
            make.top.equalTo(cigLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(dateField)
            make.height.equalTo(50)
        }

        costField.snp.makeConstraints { make in
            make.top.equalTo(cigarettesSlider.snp.bottom).offset(16)
            make.leading.trailing.equalTo(dateField)
            make.height.equalTo(40)
        }

        healthStatusField.snp.makeConstraints { make in
            make.top.equalTo(costField.snp.bottom).offset(16)
            make.leading.trailing.equalTo(dateField)
            make.height.equalTo(40)
        }

        craveLabel.snp.makeConstraints { make in
            make.top.equalTo(healthStatusField.snp.bottom).offset(16)
            make.leading.trailing.equalTo(dateField)
        }

        cravingSlider.snp.makeConstraints { make in
            make.top.equalTo(craveLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(dateField)
            make.height.equalTo(50)
        }

        notesField.snp.makeConstraints { make in
            make.top.equalTo(cravingSlider.snp.bottom).offset(16)
            make.leading.trailing.equalTo(dateField)
            make.height.equalTo(40)
        }
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(notesField.snp.bottom).offset(20)
            make.leading.trailing.equalTo(dateField)
            make.height.equalTo(45)
        }
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
    }

    private func setupTable() {
        // Header
        let headerLabel = UILabel()
        headerLabel.text = "Lịch sử nhật ký"
        headerLabel.font = .preferredFont(forTextStyle: .extraLargeTitle2)
        headerLabel.textAlignment = .center
        headerLabel.textColor = .accent
        headerLabel.numberOfLines = 0
        headerLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        tableView.tableHeaderView = headerLabel
        tableView.backgroundColor = UIColor.systemGray6
        tableView.layer.cornerRadius = 8
        tableView.register(SmokingLogCell.self, forCellReuseIdentifier: "logCell")
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let divider = UIView()
        divider.backgroundColor = .separator
        view.addSubview(divider)
        view.addSubview(tableView)
        divider.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(12)
            make.leading.trailing.equalTo(view).inset(24)
            make.height.equalTo(1)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(12)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupBlur() {
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isHidden = false
        view.addSubview(blurView)
    }

    private func fetchLogs() {
        DIContainer.shared.resolve(PackageServiceProtocol.self)!
            .fetchSmokingLogs()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] list in
                guard let self = self else { return }
                if list.isEmpty {
                    self.showToastMessage(message: "Chưa có nhật ký", icon: .icInfoFilled.withTintColor(.yellow), direction: .top)
                } else {
                    self.logs = list
                    self.tableView.reloadData()
                }
            }, onFailure: { [weak self] err in
                self?.showToastMessage(message: err.localizedDescription, icon: .icError.withTintColor(.red), direction: .top)
            })
            .disposed(by: disposeBag)
    }

    @objc private func submit() {
        let cigarettesInt = NSDecimalNumber(decimal: cigarettesSlider.indicatorValue).intValue
        let cravingInt = NSDecimalNumber(decimal: cravingSlider.indicatorValue).intValue
        let body: [String: Any] = [
            "date": dateField.text ?? "",
            "cigarettes": cigarettesInt,
            "cost": Double(costField.text ?? "") ?? 0,
            "healthStatus": healthStatusField.text ?? "",
            "cravingLevel": cravingInt,
            "notes": notesField.text ?? ""
        ]
        DIContainer.shared.resolve(PackageServiceProtocol.self)!
            .createSmokingLog(body: body)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.showToastMessage(message: "Tạo nhật ký thành công", icon: .icCheckCircle.withTintColor(.green), direction: .top)
                self?.fetchLogs()
            }, onFailure: { [weak self] err in
                self?.showToastMessage(message: err.localizedDescription, icon: .icError.withTintColor(.red), direction: .top)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Biometrics
    private func authenticate() {
        let context = LAContext()
        var err: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else { return }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: "Xác nhận để truy cập nhật ký hút thuốc") { [weak self] success, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if success {
                    self.blurView.isHidden = true
                } else {
                    // user cancelled or failed – pop back to root
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}

extension SmokingLogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath) as! SmokingLogCell
        cell.configure(with: logs[indexPath.row])
        return cell
    }
} 
