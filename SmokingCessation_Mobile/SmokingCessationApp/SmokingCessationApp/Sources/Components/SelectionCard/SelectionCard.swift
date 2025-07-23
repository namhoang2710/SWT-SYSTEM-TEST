//
//  SelectionCard.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit

public protocol SelectionCardProtocol {
    func configure(with model: SelectionCardModel)
}

public class SelectionCard: UIView, SelectionCardProtocol {
    // MARK: - Declarations
    var model: SelectionCardModel
    lazy var slotContainerView = UIView()
    lazy var errorStackContainer = UIView()
    lazy var slotContentContainerView = UIView()
    lazy var checkboxContainerView = UIView()
    lazy var errorStackView = ErrorStackView(errorMessageAlignment: .left)
    lazy var verticalStackView = UIStackView()
    var highlightLabelView: SelectionCardHighlightLabel?
    var customTopSlotView: UIView?
    var bottomSlotView: UIView?
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var firstSubTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var secondSubtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var customTopSlotConstraints: [NSLayoutConstraint] = []
    var accessibilityID: String?
    // Callbacks
    public var onStateChanged: ((SelectionCardModel) -> Void)?

    // MARK: - Constant
    struct ConstantsSelectionCard {
        static let itemContainerHeight: CGFloat = 24
        static let iconHeight: CGFloat = 16
        static let titleAndCheckboxContainerHeight: CGFloat = 24
        static let subtitleHeight = 20
    }
    // MARK: - Initializer
    public init(model: SelectionCardModel, accessibilityID: String? = nil) {
        self.model = model
        self.accessibilityID = accessibilityID
        super.init(frame: .zero)
        setupTapGesture()
        setupUI()
        /// Trigger the setup of the accessibility function.
    }

    // code coverage tool ignore
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
