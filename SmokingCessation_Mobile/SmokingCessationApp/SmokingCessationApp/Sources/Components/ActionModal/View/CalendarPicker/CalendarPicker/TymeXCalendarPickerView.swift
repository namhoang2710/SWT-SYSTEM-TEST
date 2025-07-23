//
//  CalendarPickerView.swift
//  GoTymeApp
//
//  Created by Vinh Pham on 22/06/2022.
//  Copyright © 2022 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public protocol TymeXCalendarPickerDelegate: AnyObject {
    func calendarPickerSelectDate(_ dateComponent: TymeXDateComponent)
}

open class TymeXCalendarPickerView: UIView {
    public weak var delegate: TymeXCalendarPickerDelegate?

    private let pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()

    public var minimumDate: Date? {
        didSet {
            self.updateDate(animated: false)
        }
    }

    public var maximumDate: Date? {
        didSet {
            self.updateDate(animated: false)
        }
    }

    public var date: Date {
        get {
            return self._date
        }
        set {
            self.setDate(newValue, animated: false)
        }
    }

    public var textColor: UIColor = .black {
        didSet {
            self.updateDate(animated: false)
        }
    }

    public var font: UIFont = UIFont.systemFont(ofSize: 23) {
        didSet {
            self.updateDate(animated: false)
        }
    }

    public var selectTextColor: UIColor = .black {
        didSet {
            self.updateDate(animated: false)
        }
    }

    public var selectFont: UIFont = UIFont.systemFont(ofSize: 23) {
        didSet {
            self.updateDate(animated: false)
        }
    }

    public var saturdayColor: UIColor? = UIColor(red: 31/255, green: 119/255, blue: 219/255, alpha: 1) {
        didSet {
            self.updateDate(animated: false)
        }
    }

    public var sundayColor: UIColor? = UIColor(red: 198/255, green: 51/255, blue: 42/255, alpha: 1) {
        didSet {
            self.updateDate(animated: false)
        }
    }

    public var locale: Locale? = Locale.current {
        didSet {
            self.localeType = TymeXLocalizeType.localize(locale: self.locale)
        }
    }

    public var isShowWeek = false {
        didSet {
            self.pickerView.delegate = nil
            self.pickerView.reloadAllComponents()
            self.pickerView.delegate = self
            self.updateDate(animated: false)
        }
    }

    public var dateFormatType: TymeXDateFormatType = .default {
        didSet {
            self.pickerView.delegate = nil
            self.pickerView.reloadAllComponents()
            self.pickerView.delegate = self
            self.updateDate(animated: false)
        }
    }

    public var localeType: TymeXLocalizeType = .enLocale {
        didSet {
            self.pickerView.delegate = nil
            self.pickerView.reloadAllComponents()
            self.pickerView.delegate = self
            self.updateDate(animated: false)
        }
    }

    public var selectedDateComponent: TymeXDateComponent {
        let year = self.pickerView.selectedRow(inComponent: self.localeType
            .dateIndex(.year, dateFormatType: self.dateFormatType))
        let month = self.pickerView.selectedRow(inComponent: self.localeType
            .dateIndex(.month, dateFormatType: self.dateFormatType))
        let day = self.pickerView.selectedRow(
            inComponent: localeType.dateIndex(.day, dateFormatType: dateFormatType)
        )
        var component = TymeXDateComponent()
        component.year = year + self.minimumDateComponent.year + 1
        component.month = month + 1
        component.day = day + 1
        return component
    }

    internal let years: Int = 9999
    internal let months: Int = 12
    internal var days: Int = 31

    internal var isShow = true

    private var _date = Date()
    private var dateComponent: TymeXDateComponent {
        return self.date.mxDateComponent
    }

    internal var minimumDateComponent = TymeXDateComponent()

    internal var maximumDateComponent = TymeXDateComponent()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.initVars()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()

        self.initVars()
    }

    private func initVars() {
        let pickerView = self.pickerView
        pickerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
        self.addSubview(pickerView)
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: self.topAnchor),
            pickerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            pickerView.leftAnchor.constraint(equalTo: self.leftAnchor),
            pickerView.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])

        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.updateDate(animated: false)
    }

    open func update(animated: Bool) {
        self.updateDate(animated: animated)
    }

    open func setDate(_ date: Date, animated: Bool) {
        self._date = date
        self.updateDate(animated: animated)
    }

    private func updateDate(animated: Bool) {
        self.isShow = true
        if let minimumDate = self.minimumDate, let maximumDate = self.maximumDate {
            if (minimumDate.mxDateComponent.year > maximumDate.mxDateComponent.year) ||
                (minimumDate.mxDateComponent.year == maximumDate.mxDateComponent.year &&
                 minimumDate.mxDateComponent.month > maximumDate.mxDateComponent.month) ||
                (minimumDate.mxDateComponent.year == maximumDate.mxDateComponent.year &&
                 minimumDate.mxDateComponent.month == maximumDate.mxDateComponent.month &&
                 minimumDate.mxDateComponent.day > maximumDate.mxDateComponent.day) {
                self.isShow = false
            }
        }
        self.pickerView.reloadAllComponents()
        if self.isShow {
            self.availableYearDate()
            self.availableMonthDate()
            self.availableDayDate()

            if self.updateYearDate(animated: animated) {
                if self.updateMonthDate(animated: animated) {
                    self.updateDayDate(animated: animated)
                }
            }
        }
    }

    private func availableYearDate() {
        if let minimumDate = self.minimumDate {
            self.minimumDateComponent.year = minimumDate.mxDateComponent.year - 1
        } else {
            self.minimumDateComponent.reset()
        }

        if let maximumDate = self.maximumDate {
            self.maximumDateComponent.year = self.years - maximumDate.mxDateComponent.year
        } else {
            self.maximumDateComponent.reset()
        }

        self.pickerView.reloadComponent(self.localeType.dateIndex(.year, dateFormatType: self.dateFormatType))
    }

    private func checkAndUpdateIfSelectedDateInvalid() {
        guard let selectedDate = selectedDateComponent.date else { return }
        guard let minimumDate = self.minimumDate else { return }
        guard let maximumDate = self.maximumDate else {
            if selectedDate < minimumDate {
                resetSelectedDate(to: minimumDate)
            }
            return
        }
        if selectedDate < minimumDate {
            resetSelectedDate(to: minimumDate)
        } else if selectedDate > maximumDate {
            resetSelectedDate(to: maximumDate)
        }
    }

    private func resetSelectedDate(to date: Date?) {
        guard let date = date else { return }
        self.pickerView.selectRow(
            date.mxDateComponent.year - 1,
            inComponent: self.localeType.dateIndex(.day, dateFormatType: self.dateFormatType),
            animated: true
        )
        self.pickerView.selectRow(
            date.mxDateComponent.month - 1,
            inComponent: self.localeType.dateIndex(.month, dateFormatType: self.dateFormatType),
            animated: true
        )
        self.pickerView.selectRow(
            date.mxDateComponent.day - 1,
            inComponent: self.localeType.dateIndex(.day, dateFormatType: self.dateFormatType),
            animated: true
        )
    }

    private func availableMonthDate() {
        self.checkAndUpdateIfSelectedDateInvalid()
        self.pickerView.reloadComponent(self.localeType.dateIndex(.month, dateFormatType: self.dateFormatType))
    }

    private func availableDayDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let monthValue = self.selectedDateComponent.month + 1 < 10 ?
        "0\(self.selectedDateComponent.month + 1)" : "\(self.selectedDateComponent.month + 1)"
        if let date = dateFormatter.date(from: "\(self.selectedDateComponent.yearString)-\(monthValue)-01")?
            .addingTimeInterval(-24*60*60) {
            self.days = date.mxDateComponent.day
        } else {
            self.days = 31
        }

        checkAndUpdateIfSelectedDateInvalid()
        self.pickerView.reloadComponent(self.localeType.dateIndex(.day, dateFormatType: self.dateFormatType))
    }

    @discardableResult
    private func updateYearDate(animated: Bool) -> Bool {
        if !self.isShow { return false }
        if self.dateComponent.year - self.minimumDateComponent.year - 1 < 0 { return false }
        if (self.years - self.minimumDateComponent.year - self.maximumDateComponent.year) <
            (self.dateComponent.year - self.minimumDateComponent.year - 1) {
            return false
        }

        self.pickerView.selectRow(
            self.dateComponent.year - self.minimumDateComponent.year - 1,
            inComponent: self.localeType.dateIndex(.year, dateFormatType: self.dateFormatType),
            animated: animated
        )
        return true
    }

    @discardableResult
    private func updateMonthDate(animated: Bool) -> Bool {
        if !self.isShow { return false }
        self.pickerView.selectRow(self.dateComponent.month - 1,
                                  inComponent: self.localeType.dateIndex(.month, dateFormatType: self.dateFormatType),
                                  animated: animated)
        return true
    }

    @discardableResult
    private func updateDayDate(animated: Bool) -> Bool {
        self.pickerView.selectRow(
            self.dateComponent.day - 1,
            inComponent: self.localeType.dateIndex(.day, dateFormatType: self.dateFormatType),
            animated: animated
        )
        return true
    }

    internal func checkWeek(_ value: Int) -> (week: TymeXDateComponent.TymeXWeekday, weekValue: String) {
        let value = value + 1 < 10 ? "0\(value + 1)" : "\(value + 1)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let yearString = self.selectedDateComponent.yearString
        let monthString = self.selectedDateComponent.monthString
        if let date = dateFormatter.date(from: "\(yearString)-\(monthString)-\(value)"),
            let week = date.mxDateComponent.week {
            return (week, "(\(week.value(self.localeType)))")
        }
        return (.sunday, "")
    }
}

// MARK: UIPickerViewDelegate
extension TymeXCalendarPickerView: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35.0
    }

    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return self.localeType.width(
            dateType: self.localeType.dateArray(self.dateFormatType)[component],
            isShowWeek: self.isShowWeek
        )
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.availableYearDate()
        self.availableMonthDate()
        self.availableDayDate()
        self.delegate?.calendarPickerSelectDate(self.selectedDateComponent)
    }
}
