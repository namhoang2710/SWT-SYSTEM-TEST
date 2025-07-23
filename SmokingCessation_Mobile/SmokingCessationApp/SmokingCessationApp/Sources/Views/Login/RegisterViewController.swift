import UIKit
import Lottie
import RxSwift
import RxCocoa
import SnapKit

final class RegisterViewController: UIViewController, TymeXLoadingViewable {
    // MARK: – Dependencies
    private let viewModel: RegisterViewModel
    private let disposeBag = DisposeBag()

    // MARK: – UI Elements
    var primaryButton = PrimaryButton()
    var secondaryButton = SecondaryButton()
    private var selectedDate = Date()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let confirmPasswordField = UITextField()
    private let nameField = UITextField()
    lazy var inputPickerView: TymeXInputPickerView = {
       let view = TymeXInputPickerView(rightIcon: SmokingCessation().iconCalendar)
       view.updateConfigTextField(
           placeHolder: "Nhập năm sinh",
           titleStr: "Năm sinh"
       )
       view.setLimitCharacter(100)
       view.onViewTapped = { [weak self] in
           guard let self = self else { return }
           self.showDatePickerView()
       }
       return view
   }()
    var datePickerViewController: TymeXSheetDatePickerViewController?
    let segmentControlView = TymeXSegmentControl()
    lazy var registerButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setShowLoadingForTouchUpInside(false)
        button.setTitle(with: .trailingIcon(.icRequestSentInverse, "Đăng ký"))
        return button
    }()

    private let registerAnimation: LottieAnimationView = {
        let anim = LottieAnimationView(name: SmokingCessation.registerAnimation)
               anim.contentMode = .scaleAspectFit
               anim.loopMode = .loop
            anim.play()
               return anim
    }()
    private let separatorView = UIView()
    private let loginLinkLabel = UILabel()

    init(viewModel: RegisterViewModel = RegisterViewModel(authService: DIContainer.shared.resolve(AuthServiceProtocol.self)!)) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Đăng ký"
        segmentControlView.selectColor = SmokingCessation.primaryColor
        segmentControlView.setItems([
            (title: "Nam", selectIcon: UIImage(systemName: "person.circle")?.withTintColor(.green)),
            (title: "Nữ", selectIcon: UIImage(systemName: "person.circle")?.withTintColor(.systemPink)),
        ]) { [weak self] index in
            guard let self = self else { return }
            switch index {
            case 0:
                viewModel.gender.accept("Male")
            case 1:
                viewModel.gender.accept("Female")
            default:
                viewModel.gender.accept("Male")
            }
        }
        
        [registerAnimation,emailField, passwordField, confirmPasswordField, nameField,inputPickerView, segmentControlView, registerButton].forEach {
            view.addSubview($0)
        }
        [separatorView, loginLinkLabel].forEach { view.addSubview($0) }

        emailField.placeholder = "Email"
        emailField.autocapitalizationType = .none
        emailField.borderStyle = .roundedRect
        passwordField.placeholder = "Mật khẩu"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        confirmPasswordField.placeholder = "Nhập lại mật khẩu"
        confirmPasswordField.borderStyle = .roundedRect
        confirmPasswordField.isSecureTextEntry = true
        nameField.placeholder = "Tên"
        nameField.borderStyle = .roundedRect
        separatorView.backgroundColor = .lightGray.withAlphaComponent(0.6)
        loginLinkLabel.isUserInteractionEnabled = true
        loginLinkLabel.attributedText = NSAttributedString(string: "Đăng nhập", attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.accent
        ])

        // Layout using SnapKit
        registerAnimation.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalTo(view)
            make.width.height.equalTo(200)
        }
        
        emailField.snp.makeConstraints { make in
            make.top.equalTo(registerAnimation.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(40)
        }
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(15)
            make.leading.trailing.equalTo(emailField)
            make.height.equalTo(40)
        }
        confirmPasswordField.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(15)
            make.leading.trailing.equalTo(emailField)
            make.height.equalTo(40)
        }
        nameField.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordField.snp.bottom).offset(15)
            make.leading.trailing.equalTo(emailField)
            make.height.equalTo(40)
        }
        inputPickerView.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom).offset(15)
            make.leading.trailing.equalTo(emailField)
//            make.height.equalTo(60)
        }
        segmentControlView.snp.makeConstraints { make in
            make.top.equalTo(inputPickerView.snp.bottom).offset(15)
            make.leading.trailing.equalTo(emailField)
            make.height.equalTo(40)
        }
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(segmentControlView.snp.bottom).offset(25)
            make.centerX.equalTo(view)
            make.height.equalTo(45)
            make.leading.trailing.equalToSuperview().inset(60)
        }

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view).inset(40)
            make.height.equalTo(1)
        }

        loginLinkLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(12)
            make.centerX.equalTo(view)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLogin))
        loginLinkLabel.addGestureRecognizer(tap)
    }

    private func bindViewModel() {
        emailField.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)
        passwordField.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        confirmPasswordField.rx.text.orEmpty.bind(to: viewModel.confirmPassword).disposed(by: disposeBag)
        nameField.rx.text.orEmpty.bind(to: viewModel.name).disposed(by: disposeBag)
//        inputPickerView.rx.text.orEmpty.bind(to: viewModel.age).disposed(by: disposeBag)
//        genderField.rx.text.orEmpty.bind(to: viewModel.gender).disposed(by: disposeBag)

        registerButton.rx.tap.bind(to: viewModel.registerTapped).disposed(by: disposeBag)

        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                if loading {
                    self?.mxShowFullScreenLoadingView(duration: 0, lottieAnimationName: SmokingCessation.loadingAnimation, bundle: BundleSmokingCessation.bundle)
                }
            })
            .disposed(by: disposeBag)

        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { message in
                self.showToastMessage(message: message, icon: .icError.withTintColor(.red), direction: .top)
            })
            .disposed(by: disposeBag)

        viewModel.registerSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                print("Register success")
                self.showToastMessage(message: "Đăng ký thành công", icon: .icCheckCircle.withTintColor(.green), direction: .top)
                self.showSuccessScreen()
            })
            .disposed(by: disposeBag)
    }

    @objc private func didTapLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    // show guide screen function
    func showSuccessScreen() {
        let dismissButton = PrimaryButton()
        dismissButton.setTitle(with: .text("Xác nhận"))
        dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        let checkEmail: LottieAnimationView = {
            let anim = LottieAnimationView(name: SmokingCessation.checkEmailAnimation)
                       anim.contentMode = .scaleAspectFit
                       anim.loopMode = .loop
                        anim.play()
                       return anim
            }()
        var stepGuidelineContents: [StepGuidelineContent] =
            [
                StepGuidelineContent(title: "Kiểm tra trong hộp thư của bạn email chúng tôi đã gửi", subTitle: "Email có thể nằm trong mục spam", isTitleHighlighted: true),
                StepGuidelineContent(title: "Ấn vào đường link có dòng chữ `for mobile app:...`"),
                StepGuidelineContent(title: "Chuyển hướng về lại app tự động và đăng nhập bằng tài khoản bạn vừa tạo", subTitle: "Tài khoản của bạn sẽ được tự động xác thực khi được chuyển hướng về lại app")
            ]
            let guideScreenSuccess = GuideScreen(
            topContentView: GuideScreenTopView(
                topPictogramView: checkEmail,
                title: "Email xác thực đã được gửi",
                subTitle: "Hãy kiểm tra đường link được chúng tôi gửi để xác thực tài khoản"
            ),
            mainContentType: .step(stepGuidelineContents),
            buttonDock: ButtonDock(
                buttons: [
                    dismissButton
                ],
                displayMode: .alwayHideSeperator
            ))
        mxPresentActionModal(guideScreenSuccess)
    }
    // MARK: Input date picker
    func showDatePickerView() {
        let primaryButton = makePrimaryBtn(title: "Select")
        let secondaryButton = makeSecondaryBtn(title: "Cancel")
        let controller = TymeXSheetDatePickerViewController(
            selectedDate: selectedDate,
            fromDate: nil,
            toDate: nil,
            locale: .current,
            actions: [primaryButton, secondaryButton]
        )
        mxPresentActionModal(controller)
        controller.onSelectedDate = { date in
            self.selectedDate = date
        }
        datePickerViewController = controller
    }
    
    func makePrimaryBtn(title: String) -> PrimaryButton {
        let button = PrimaryButton()
        button.addTarget(self, action: #selector(actionSheetsButtonTouchUpInside(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(with: .text(title))
        primaryButton = button
        return button
    }

    func makeSecondaryBtn(title: String) -> SecondaryButton {
        let button = SecondaryButton()
        button.addTarget(self, action: #selector(actionSheetsButtonTouchUpInside(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.hideLoading()
        button.setTitle(with: .text(title))
        secondaryButton = button
        return button
    }
    
    @objc public func actionSheetsButtonTouchUpInside(_ sender: BaseButton) {
        if sender == primaryButton {
            guard let selectedDate = datePickerViewController?.getSelectedDate() else { return }
            print("Ngày sinh: \(selectedDate)")
            let calendar = Calendar.current
//            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())
            let today = calendar.startOfDay(for: Date())
              let inputDay = calendar.startOfDay(for: selectedDate)
//            let selectedDateString = selectedDate.toString(dateFormat: CoreConstants.DateFormat.yearMonthDay)
//            let tomorrowDateString = tomorrow?.toString(dateFormat: CoreConstants.DateFormat.yearMonthDay)
            let todayYearString = today.toString(dateFormat: CoreConstants.DateFormat.yearOnly)
            let inputYearString = inputDay.toString(dateFormat: CoreConstants.DateFormat.yearOnly)
            self.inputPickerView.updateTextField(content: inputYearString)
            if todayYearString < inputYearString {
                self.inputPickerView.showMessage(with: "Bạn không thể sinh trong tương lai", isError: true)
            } else {
                inputPickerView.updateMessageContentViews(inputYearString, withState: .loseFocus)
                viewModel.age.accept(inputYearString)
            }
            print("Năm sinh: \(inputYearString)")
        }
        dismiss(animated: true) {}
    }
}
