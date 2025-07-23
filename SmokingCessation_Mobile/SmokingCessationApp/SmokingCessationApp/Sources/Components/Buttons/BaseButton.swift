//
//  BaseButton.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import UIKit
import Lottie

open class BaseButton: UIControl {
    var backgroundView = UIView()
    var animContainerView = UIView()
    var titleView = UIStackView()
    lazy var textLabel = UILabel()
    lazy var imageView = UIImageView()
    var animatedWidthByParentWidth: NSLayoutConstraint?
    var animatedWidthByMinWidth: NSLayoutConstraint?
    var highlightedWidth: NSLayoutConstraint?
    var height: CGFloat { 48 }
    var minWidth: CGFloat { 72 }
    var normalColor: UIColor = SmokingCessation.primaryColor
    var highlightedColor: UIColor = SmokingCessation.primaryColor.withAlphaComponent(0.8)
    var normalBorderWidth: CGFloat { 0 }
    var highlightedBorderWidth: CGFloat { 0 }
    var configuration: ButtonConfiguration = ButtonConfiguration()

    private var loadingWorkItem: DispatchWorkItem?

    lazy var imageViewWithConstraint: NSLayoutConstraint = {
        return self.imageView.widthAnchor.constraint(equalToConstant: configuration.iconWidth)
    }()

    lazy var animContainerViewWidthConstraint: NSLayoutConstraint = {
        return self.animContainerView.widthAnchor.constraint(equalToConstant: configuration.animationSize)
    }()

    open var titleTypography: [NSAttributedString.Key: Any] { SmokingCessation.textLabelEmphasizeM }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: Config UI
    func configColors() {
        // Override to config colors of elements
    }

    func configTitleView() {
        // Override to config titles of view
    }

    func configBackgroundView() {
        backgroundView.clipsToBounds = true
        backgroundView.backgroundColor = normalColor
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = getCornerRadiusBase()
        backgroundView.layer.cornerRadius = getCornerRadiusBase()
    }

    public func setTitle(with mode: ButtonConfiguration.ContentMode) {
        switch mode {
        case .text(let text):
            imageView.removeFromSuperview()
            titleView.addArrangedSubview(textLabel)
            textLabel.attributedText = NSAttributedString(string: text, attributes: titleTypography)
            accessibilityLabel = text
        case .trailingIcon(let image, let text):
            if let image = image {
                titleView.addArrangedSubview(imageView)
                imageView.image = image
            } else {
                imageView.removeFromSuperview()
            }
            titleView.addArrangedSubview(textLabel)
            textLabel.attributedText = NSAttributedString(string: text, attributes: titleTypography)
            accessibilityLabel = text
        }
        configTitleView()
        textLabel.accessibilityIdentifier = "textLabel\(type(of: self))"
    }

    public func setTitle(with mode: ButtonConfiguration.ContentMode, textColor: UIColor) {
        setTitle(with: mode)
        setTitleColor(textColor)
    }

    public func setTitleColor(_ textColor: UIColor) {
        textLabel.textColor = textColor
    }

    public func setShowLoadingForTouchUpInside(_ isLoading: Bool) {
        configuration.showLoadingForTouchUpInside = isLoading
    }

    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        highlightBackground(true)
        return super.beginTracking(touch, with: event)
    }

    open override func cancelTracking(with event: UIEvent?) {
        highlightBackground(false)
        return super.cancelTracking(with: event)
    }

    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touchPoint = touch?.location(in: self), bounds.contains(touchPoint),
           configuration.showLoadingForTouchUpInside {
            showLoading {
                // Call highlightBackground(false) here will make wrong background color when loading
            }
        } else {
            highlightBackground(false)
        }
        return super.endTracking(touch, with: event)
    }

    // MARK: Public Funcs
    open func showLoading(completion: @escaping () -> Void) {
        // Cancel any in-progress work before starting a new one
        loadingWorkItem?.cancel()

        // Create a new DispatchWorkItem for showing loading
        loadingWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.executeShowLoading(completion: completion)
            }
        }

        // Dispatch the work item to the main queue
        if let workItem = loadingWorkItem {
            DispatchQueue.main.async(execute: workItem)
        }
    }

    private func hideLoadingIfNeeded() {
        guard !animContainerView.subviews.isEmpty else { return }
        highlightBackground(false)
        isUserInteractionEnabled = true
        removeAnimationView()
        animatedWidthByParentWidth?.isActive = true
        animatedWidthByMinWidth?.isActive = false
        titleView.alpha = 1
    }

    open func hideLoading(animation: Bool = true) {
        // Cancel any in-progress work before starting a new one
        loadingWorkItem?.cancel()

        // Create a new DispatchWorkItem for hiding loading
        loadingWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.executeHideLoading()
            }
        }
        // Dispatch the work item to the main queue
        if let workItem = loadingWorkItem {
            DispatchQueue.main.async(execute: workItem)
        }
    }

    // Refactor the original showLoading code to a private method
    private func executeShowLoading(completion: @escaping () -> Void) {

        hideLoadingIfNeeded()
        isUserInteractionEnabled = false
        addAnimationView()
        animatedWidthByParentWidth?.isActive = false
        animatedWidthByMinWidth?.isActive = true
        UIView.animate(
            withDuration: 350/1000,
            animations: {
                self.layoutIfNeeded()
            })

        BaseButtonAnimator().showLoading(
            minWidth: minWidth,
            views: LoadingViews(
                button: self,
                animationContainerView: animContainerView,
                animatedWidth: animatedWidthByMinWidth,
                backgroundView: backgroundView,
                titleView: titleView,
                titleLabel: textLabel,
                titleIcon: imageView
            ),
            completion: completion
        )
    }

    // Refactor the original hideLoading code to a private method
    private func executeHideLoading() {
        guard !animContainerView.subviews.isEmpty else { return }
        highlightBackground(false)
        isUserInteractionEnabled = true
        removeAnimationView()
        animatedWidthByParentWidth?.isActive = true
        animatedWidthByMinWidth?.isActive = false

        titleView.alpha = 0
        UIView.animate(
            withDuration: 350/1000,
            animations: {
                self.layoutIfNeeded()
            })
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.5, options: [.curveEaseInOut],
            animations: {
                self.layoutIfNeeded()
            }, completion: { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.titleView.alpha = 1
                }
            }
        )
    }

    open func setup(configuration: ButtonConfiguration) {
        self.configuration = configuration
        setupUI()
        setTitle(with: configuration.contentMode)
    }

    @discardableResult
    open func change(normalColor: UIColor, highlightedColor: UIColor) -> Self {
        self.normalColor = normalColor
        self.highlightedColor = highlightedColor
        configBackgroundView()
        return self
    }
}

// MARK: - Privates
extension BaseButton {
    private func commonInit() {
        configColors()
        setupUI()
        configBackgroundView()
        configTitleView()
    }

    // MARK: Layout UI
    private func setupUI() {
        backgroundColor = nil
        isAccessibilityElement = true
        subviews.forEach {
            $0.removeFromSuperview()
        }
        backgroundView.subviews.forEach {
            $0.removeFromSuperview()
        }
        imageViewWithConstraint.isActive = false
        animContainerViewWidthConstraint.isActive = false

        layoutBackgroundView()
        layoutAnimationView()
        layoutTitleView()
    }

    private func layoutBackgroundView() {
        let stackView = UIStackView(arrangedSubviews: [UILabel(), backgroundView, UILabel()])
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill

        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: height)
        ])

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        animatedWidthByParentWidth = backgroundView.widthAnchor.constraint(equalTo: widthAnchor)
        animatedWidthByMinWidth = backgroundView.widthAnchor.constraint(equalToConstant: minWidth)
        animatedWidthByParentWidth?.isActive = true
        animatedWidthByMinWidth?.isActive = false
        stackView.isUserInteractionEnabled = false
    }

    private func layoutAnimationView() {
        backgroundView.addSubview(animContainerView)
        animContainerView.translatesAutoresizingMaskIntoConstraints = false
        animContainerViewWidthConstraint.isActive = true
        animContainerViewWidthConstraint.constant = configuration.animationSize
        NSLayoutConstraint.activate([
            animContainerView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            animContainerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            animContainerView.heightAnchor.constraint(equalTo: animContainerView.widthAnchor)
        ])
    }

    private func layoutTitleView() {
        imageView.contentMode = .scaleAspectFit
        titleView.axis = .horizontal
        titleView.spacing = configuration.trailingIconSpacing
        titleView.distribution = .fill
        backgroundView.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        imageViewWithConstraint.constant = configuration.iconWidth
        imageViewWithConstraint.isActive = true
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            titleView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            titleView.leadingAnchor.constraint(
                greaterThanOrEqualTo: backgroundView.leadingAnchor, constant: 12
            ),
            titleView.trailingAnchor.constraint(
                lessThanOrEqualTo: backgroundView.trailingAnchor, constant: 12
            )
        ])
        if let trailingTitleSpacing = configuration.trailingTitleSpacing {
            titleView.trailingAnchor
                .constraint(equalTo: backgroundView.trailingAnchor, constant: trailingTitleSpacing)
                .isActive = true
        }
    }

    private func removeAnimationView() {
        animContainerView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }

    private func addAnimationView() {
        guard let animationView = BaseButtonAnimator().makeLoadingContentView(
            lottieAnimationName: configuration.lottieAnimationName
        ) else {
            return
        }
        animContainerView.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalToConstant: configuration.animationSize),
            animationView.widthAnchor.constraint(equalToConstant: configuration.animationSize),
            animationView.centerXAnchor.constraint(equalTo: animContainerView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: animContainerView.centerYAnchor)
        ])
    }

    private func highlightBackground(_ isHighlighted: Bool, keepState: Bool = false) {
        BaseButtonAnimator().highlightView(
            backgroundView,
            isHighlighted: isHighlighted,
            configuration: HighlightViewConfiguration(
                normalColor: normalColor, highlightedColor: highlightedColor, cornerRadius: getCornerRadiusBase(),
                highlightedBorderWidth: highlightedBorderWidth, normalBorderWidth: normalBorderWidth
            )
        )
    }
}
