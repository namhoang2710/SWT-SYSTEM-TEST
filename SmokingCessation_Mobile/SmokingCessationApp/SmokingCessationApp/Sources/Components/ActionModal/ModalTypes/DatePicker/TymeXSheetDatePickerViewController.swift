//
//  TymeXSheetDatePickerViewController.swift
//  TymeXUIComponent
//
//  Created by Anh Tran on 24/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import RxSwift
import UIKit

public final class TymeXSheetDatePickerViewController: TymeXActionModalBaseViewController {
    @IBOutlet private weak var contentView: UIView!

    @IBOutlet private weak var buttonsStackView: UIStackView!

    @IBOutlet private weak var startDatePicker: TymeXDatePickerView!

    let highlightedView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    var isShowDragIndicator = false
    private var locale: Locale?
    private var fromDate: Date?
    private var toDate: Date?
    private var actions: [UIControl] = []
    private var selectedDate: Date?

    // MARK: CallBacks

    public var onSelectedDate: ((Date) -> Void)?

    public init(
        selectedDate: Date?,
        fromDate: Date?,
        toDate: Date?,
        locale: Locale? = .current,
        actions: [UIControl]
    ) {
        self.fromDate = fromDate
        self.toDate = toDate
        self.locale = locale
        self.actions = actions
        self.selectedDate = selectedDate
        super.init(nibName: Self.nibIdentifier, bundle: BundleSmokingCessationComponent.bundle)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setup(
            selectedDate: selectedDate,
            fromDate: fromDate,
            toDate: toDate,
            locale: locale,
            actions: actions
        )
    }

    private func setup(
        selectedDate: Date?,
        fromDate: Date?,
        toDate: Date?,
        locale: Locale? = .current,
        actions: [UIControl]
    ) {
        applyModalBorderToContentView(contentView)
        startDatePicker.datePickerView.minimumDate = fromDate
        startDatePicker.datePickerView.maximumDate = toDate
        startDatePicker.datePickerView.locale = locale
        startDatePicker.datePickerView.setDate(selectedDate ?? Date(), animated: true)
        startDatePicker.isHidden = false
        startDatePicker.valueChange = { [weak self] datecomponent in
            guard let self = self, let date = datecomponent.date else { return }
            self.onSelectedDate?(date)
        }

        buttonsStackView.spacing = SmokingCessation.spacing4
        buttonsStackView.mxRemoveAllSubviews()

        for action in actions {
            buttonsStackView.addArrangedSubview(action)
        }
        view.layoutIfNeeded()
    }

    func bindingDate(_ datecomponent: TymeXDateComponent, control: UIButton) {
        if let date = datecomponent.date {
            let dateformater = DateFormatter()
            dateformater.dateFormat = "MMMM dd yyyy"
            let dateString = dateformater.string(from: date)
            control.setTitle(dateString, for: .normal)
        }
    }

    public func getSelectedDate() -> Date? {
        return startDatePicker.datePickerView.selectedDateComponent.date
    }

    // MARK: - ActionModalPresentable

    override public var mxShortFormHeight: TymeXActionModalHeight {
        return .contentHeight(contentView.frame.size.height)
    }

    override public var mxShowDragIndicator: Bool {
        return isShowDragIndicator
    }

    override public var mxAllowsDragToDismiss: Bool {
        return isShowDragIndicator
    }
}
