//
//  ButtonDock.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

public class ButtonDock: UIView {
    @available(*, deprecated, message: "Please use `displayMode` instead.")
    var needShowLineView: Bool = true
    var allowHandleKeyboard: Bool = true
    var bgColor: UIColor = .white
    var feeFooterModels: [FeeModel] = []
    var termsFeeStatus: TermsFeeStatus = .none
    var errorMessage: String = ""
    var helperMessage: String = ""
    var buttons: [UIView] = []
    var slotView: UIView?
    let disposeBag = DisposeBag()
    var safeAreaInset: UIEdgeInsets = .zero

    // Constraints
    var containerViewBottomConstraint: NSLayoutConstraint!

    struct Constants {
        static let widthErrorIcon = 16.0
        static let defaultTextValue = "---"
    }

    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var mainStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var mainFeeStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var termStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .firstBaseline
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var termLabel: UILabel = {
        let termLabel = UILabel()
        termLabel.translatesAutoresizingMaskIntoConstraints = false
        termLabel.numberOfLines = 0
        termLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        termLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        return termLabel
    }()

    lazy var checkbox: Checkbox = {
        let checkbox = Checkbox()
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        return checkbox
    }()

    lazy var errorStackView: ErrorStackView = {
        let stack = ErrorStackView()
        return stack
    }()

    lazy var errorContainer: UIView = {
        let errorContainer = UIView()
        return errorContainer
    }()

    lazy var helperLabel: UILabel = {
        let helperLabel = UILabel()
        helperLabel.translatesAutoresizingMaskIntoConstraints = false
        helperLabel.numberOfLines = 0
        return helperLabel
    }()

    var stackViewAdditionalFee: (UIStackView, UILabel, UILabel, UILabel)?
    var stackViewFee: (UIStackView, UILabel, UILabel, UILabel)?
    var stackViewAmountAfterFee: (UIStackView, UILabel, UILabel, UILabel)?

    var displayMode: ButtonDockDisplayMode = .none

    public init(
        needShowLineView: Bool = true,
        allowHandleKeyboard: Bool = true,
        backgroundColor: UIColor = .white,
        termsFeeStatus: TermsFeeStatus = .none,
        errorMessage: String = "",
        buttons: [UIView] = [],
        helperMessage: String = "",
        slotView: UIView? = nil,
        displayMode: ButtonDockDisplayMode = .none
    ) {
        self.needShowLineView = needShowLineView
        self.allowHandleKeyboard = allowHandleKeyboard
        self.bgColor = backgroundColor
        self.termsFeeStatus = termsFeeStatus
        self.errorMessage = errorMessage
        self.buttons = buttons
        self.helperMessage = helperMessage
        self.slotView = slotView
        self.displayMode = displayMode
        super.init(frame: .zero)
        setupView()
    }

    public func resetValues() {
        stackViewAdditionalFee?.1.text = Constants.defaultTextValue
        stackViewAdditionalFee?.2.text = Constants.defaultTextValue
        stackViewFee?.1.text = Constants.defaultTextValue
        stackViewFee?.2.text = Constants.defaultTextValue
        stackViewAmountAfterFee?.1.text = Constants.defaultTextValue
        stackViewAmountAfterFee?.2.text = Constants.defaultTextValue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func stackView(for type: FeeType) -> (UIStackView, UILabel, UILabel, UILabel)? {
        switch type {
        case .additionalFee:
            return stackViewAdditionalFee
        case .fee:
            return stackViewFee
        case .amountAfterFee:
            return stackViewAmountAfterFee
        case .none:
            return nil
        }
    }

    static func createFeeStackView(
        model: FeeModel
    ) -> (UIStackView, UILabel, UILabel, UILabel) {
        let labelName = UILabel()
        labelName.numberOfLines = 0
        labelName.lineBreakMode = .byWordWrapping
        let labelAttribute = SmokingCessation.textLabelDefaultS.color(.gray)
        labelName.attributedText = NSAttributedString(string: model.feeName, attributes: labelAttribute)
        labelName.accessibilityIdentifier = "labelNameTymeXButtonDock_\(model.type.rawValue)"

        let imageView = UIImageView(image: model.feeIcon)
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.widthErrorIcon),
            imageView.heightAnchor.constraint(equalToConstant: Constants.widthErrorIcon)
        ])
        imageView.accessibilityIdentifier = "imageViewTymeXButtonDock_\(model.type.rawValue)"

        let labelAmount = UILabel()
        labelAmount.numberOfLines = 0
        let labelAmountAttribute = SmokingCessation.textLabelEmphasizeS.color(.black)
        labelAmount.attributedText = NSAttributedString(
            string: Constants.defaultTextValue,
            attributes: labelAmountAttribute
        )
        labelAmount.accessibilityIdentifier = "labelAmountTymeXButtonDock_\(model.type.rawValue)"

        let labelDescription = UILabel()
        labelDescription.numberOfLines = 0
        let labelDescriptionAttribute = SmokingCessation.textBodyDefaultM.color(.gray).alignment(.right)
        labelDescription.attributedText = NSAttributedString(
            string: Constants.defaultTextValue,
            attributes: labelDescriptionAttribute
        )
        labelDescription.accessibilityIdentifier = "labelDescriptionTymeXButtonDock_\(model.type.rawValue)"

        let horizontalStackView = UIStackView(arrangedSubviews: [labelName, UIView(), imageView, labelAmount])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 4
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false

        let verticalSubviews = model.description.isEmpty ?
            [horizontalStackView] : [horizontalStackView, labelDescription]
        let verticalStackView = UIStackView(arrangedSubviews: verticalSubviews)
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 4
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false

        return (verticalStackView, labelAmount, labelDescription, labelName)
    }

    func getModel(type: FeeType) -> FeeModel? {
        for model in feeFooterModels where model.type == type {
            return model
        }
        return nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
