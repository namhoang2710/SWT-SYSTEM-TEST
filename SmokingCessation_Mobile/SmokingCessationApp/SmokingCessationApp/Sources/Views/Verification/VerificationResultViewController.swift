import UIKit
import Lottie

final class VerificationResultViewController: UIViewController {
    enum ResultType {
        case success(message: String)
        case failure(message: String)

        var animationName: String {
            switch self {
            case .success:
                return SmokingCessation.verificationSuccessAnimation
            case .failure:
                return SmokingCessation.verificationFailedAnimation
            }
        }

        var titleText: String {
            switch self {
            case .success:
                return "Xác thực thành công"
            case .failure:
                return "Xác thực thất bại"
            }
        }

        var buttonTitle: String { "Đóng" }
    }

    private let result: ResultType
    private let animationView = LottieAnimationView()
    private let messageLabel = UILabel()
    private let dismissButton = PrimaryButton()

    private let onDismiss: (() -> Void)?

    init(result: ResultType, onDismiss: (() -> Void)? = nil) {
        self.result = result
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.clipsToBounds = true
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])

        // Animation
        let lottie = LottieAnimationView(name: result.animationName)
        lottie.contentMode = .scaleAspectFit
        lottie.loopMode = .loop
        lottie.play()

        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.text = result.titleText
        if case .success(let msg) = result {
            messageLabel.text = msg
        } else if case .failure(let msg) = result {
            messageLabel.text = msg
        }

        dismissButton.setTitle(with: .text(result.buttonTitle))
        dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [lottie, messageLabel, dismissButton])
        stack.axis = .vertical
        stack.spacing = 16
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            lottie.heightAnchor.constraint(equalToConstant: 120),
            dismissButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    @objc private func dismissSelf() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
} 
