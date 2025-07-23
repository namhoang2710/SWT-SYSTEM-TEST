import UIKit
import RxSwift
import SnapKit

final class CoachScheduleViewController: UIViewController, TymeXLoadingViewable {
    private let disposeBag = DisposeBag()
    private let viewModel: CoachScheduleViewModel
    private let listView = TymeXListViewV2()
    private let refreshControl = UIRefreshControl()
    private var schedulesData: [CoachSchedule] = [] // list currently displayed
    private var allSchedules: [CoachSchedule] = []  // raw list from server
    // MARK: – Date picker helpers
    private var selectedDate = Date()
    private var datePickerViewController: TymeXSheetDatePickerViewController?
    private var primaryButton = PrimaryButton()
    private var secondaryButton = SecondaryButton()
    private lazy var inputPickerView: TymeXInputPickerView = {
        let view = TymeXInputPickerView(rightIcon: SmokingCessation().iconCalendar)
        view.updateConfigTextField(
            placeHolder: "Chọn ngày",
            titleStr: "Ngày tập"
        )
        view.setLimitCharacter(20)
        view.onViewTapped = { [weak self] in
            self?.showDatePickerView()
        }
        return view
    }()
    private let coachName: String
    
    init(coachId: Int, coachName: String) {
        self.viewModel = CoachScheduleViewModel(coachId: coachId, service: DIContainer.shared.resolve(CoachServiceProtocol.self)!)
        self.coachName = coachName
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Add list first, then picker to ensure picker stays above list in the view hierarchy
        view.addSubview(listView)
        view.addSubview(inputPickerView)

        inputPickerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.trailing.equalTo(view).inset(20)
        }

        listView.snp.makeConstraints { make in
            make.top.equalTo(inputPickerView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view)
        }

        // refresh control
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        listView.getTableView().refreshControl = refreshControl

        bind()
        viewModel.loadTrigger.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //top navigation
        let stylist = NavigationBarStylist(
            mode: .light(),
            title: "Lịch huấn luyện viên",
            subTitle: coachName,
            rightIcon: UIImage(systemName: "message")
        )
        mxApplyNavigationBy(
            stylist: stylist,
            leftAction: { [weak self] in
            guard let self = self else {
                return
            }
            self.navigationController?.popViewController(animated: true)
        },
            rightAction: { [weak self] in
                guard let self = self else {
                    return
                }
                self.navigationController?.pushViewController(UIViewController(), animated: false)
            }
        )
    }

    private func bind() {
        viewModel.schedules
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] list in
                guard let self = self else { return }
                self.allSchedules = list
                self.updateList(with: list)
            })
            .disposed(by: disposeBag)

        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in
                let alert = UIAlertController(title: "Lỗi", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Đóng", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)

        // loading
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let self = self else { return }
                if loading {
                    self.mxShowFullScreenLoadingView(duration: 0, lottieAnimationName: SmokingCessation.loadingAnimation, bundle: BundleSmokingCessation.bundle)
                } else {
                    self.tymeXHideLoadingView()
                    self.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        // observe booking success
        viewModel.bookingSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showToastMessage(message: "Đặt lịch thành công", icon: .icCheckCircle.withTintColor(.green), direction: .top)
                self?.navigationController?.popToRootViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func updateList(with schedules: [CoachSchedule]) {
        // If user picked a date, filter schedules to the same day; otherwise show all
        let filtered = filterSchedulesIfNeeded(schedules)
        self.schedulesData = filtered
        // Prepare formatters once to reuse inside the map
        let iso = ISO8601DateFormatter(); iso.formatOptions = [.withInternetDateTime]
        let fallback = DateFormatter()
        fallback.locale = Locale(identifier: "en_US_POSIX")
        fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let items = filtered.map { sch -> TymeXListItemModelV2 in
            // Try ISO-8601 first, then fallback formatter when the server omits timezone
            let start = iso.date(from: sch.startTime) ?? fallback.date(from: sch.startTime) ?? Date()
            let end = iso.date(from: sch.endTime) ?? fallback.date(from: sch.endTime) ?? Date()
            print("[Schedule] Parsed start: \(sch.startTime) → \(start); end: \(sch.endTime) → \(end)")
            let df = DateFormatter()
            df.dateStyle = .short; df.timeStyle = .medium
            let title = df.string(from: start) + " đến " + df.string(from: end)
            let leading = TymeXLeadingContent(title: title,
                                               isHighlightTitle: true,
                                              addOnLabelStatus: sch.booked ? .red("Đã được đặt") : .green("Còn trống"),
                                              addOnButtonStatus:  !sch.booked ? .tertiaryContained("Đặt lịch ngay!") : .tertiaryOutlined("Lịch đã được đặt")
            )
            return TymeXListItemModelV2(
                leadingContent: leading,
                trailingStatus: .icon(.icClock),
                listType: .standard
            )
        }
        let model = TymeXListModelV2(shouldClearBackgroundColor: true, items: items)
        listView.configuration(with: model)

        listView.willDisplayItem = { [weak self] _, cell in
            guard let self = self else { return }

            let tableView = self.listView.getTableView()
            if let indexPath = tableView.indexPath(for: cell) {
                let booked = self.schedulesData[indexPath.row].booked
                cell.isUserInteractionEnabled = !booked
                cell.contentView.alpha = booked ? 0.5 : 1.0
            }
        }
        listView.didSelectItem = { [weak self] index, _ in
            guard let self = self else { return }
            let schedule = self.schedulesData[index]
            self.presentBookingConfirm(slotId: schedule.id)
        }
    }

    private func presentBookingConfirm(slotId: Int) {
        let alert = UIAlertController(title: "Xác nhận", message: "Bạn muốn đặt lịch này?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: { _ in
            self.bookSlot(slotId: slotId)
        }))
        present(alert, animated: true)
    }

    private func bookSlot(slotId: Int) {
        viewModel.bookSlotTrigger.accept(slotId)
    }

    @objc private func refreshPulled() {
        viewModel.loadTrigger.accept(())
    }

    // MARK: – Date picker presenter & handlers
    private func showDatePickerView() {
        let primaryButton = makePrimaryBtn(title: "Chọn ngày này")
        let secondaryButton = makeSecondaryBtn(title: "Huỷ")
        let controller = TymeXSheetDatePickerViewController(
            selectedDate: selectedDate,
            fromDate: nil,
            toDate: nil,
            locale: .current,
            actions: [primaryButton, secondaryButton]
        )
        mxPresentActionModal(controller)
        controller.onSelectedDate = { [weak self] date in
            guard let self = self else { return }
            self.selectedDate = date
        }
        datePickerViewController = controller
    }

    private func makePrimaryBtn(title: String) -> PrimaryButton {
        let button = PrimaryButton()
        button.addTarget(self, action: #selector(actionSheetsButtonTouchUpInside(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(with: .text(title))
        primaryButton = button
        return button
    }

    private func makeSecondaryBtn(title: String) -> SecondaryButton {
        let button = SecondaryButton()
        button.addTarget(self, action: #selector(actionSheetsButtonTouchUpInside(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(with: .text(title))
        secondaryButton = button
        return button
    }

    @objc private func actionSheetsButtonTouchUpInside(_ sender: BaseButton) {
        if sender == primaryButton {
            guard let picked = datePickerViewController?.getSelectedDate() else { return }
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let inputDay = calendar.startOfDay(for: picked)
            let dateString = inputDay.toString(dateFormat: CoreConstants.DateFormat.yearMonthDay)
            inputPickerView.updateTextField(content: dateString)
            if inputDay < today {
                inputPickerView.showMessage(with: "Không thể chọn ngày quá khứ", isError: true)
            } else {
                inputPickerView.updateMessageContentViews(dateString, withState: .loseFocus)
                selectedDate = inputDay
                // Filter and refresh list from master schedules
                self.updateList(with: allSchedules)
            }
        } else {
            inputPickerView.textView.text = ""
            updateList(with: allSchedules)
        }
        dismiss(animated: true)
    }

    // Helper: filter schedules to selected day (returns all if nothing chosen yet)
    private func filterSchedulesIfNeeded(_ schedules: [CoachSchedule]) -> [CoachSchedule] {
        // If picker hasn't been confirmed (text empty) -> return original list sorted by date ascending
        guard !(inputPickerView.textInputed.isEmpty) else {
            return schedules.sorted(by: { $0.startTime < $1.startTime })
        }

        let iso = ISO8601DateFormatter(); iso.formatOptions = [.withInternetDateTime]
        let fallback = DateFormatter(); fallback.locale = Locale(identifier: "en_US_POSIX"); fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let calendar = Calendar.current
        return schedules.filter { sch in
            let date = iso.date(from: sch.startTime) ?? fallback.date(from: sch.startTime)
            guard let d = date else { return false }
            return calendar.isDate(d, inSameDayAs: selectedDate)
        }.sorted { a, b in
            let d1 = iso.date(from: a.startTime) ?? fallback.date(from: a.startTime) ?? Date()
            let d2 = iso.date(from: b.startTime) ?? fallback.date(from: b.startTime) ?? Date()
            return d1 < d2
        }
    }
}
