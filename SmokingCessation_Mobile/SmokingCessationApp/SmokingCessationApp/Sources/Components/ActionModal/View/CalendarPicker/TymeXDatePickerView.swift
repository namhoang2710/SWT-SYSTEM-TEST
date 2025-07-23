//
//  TymeDatePickerView.swift
//  GoTymeApp
//
//  Created by Vinh Pham on 16/06/2022.
//  Copyright © 2022 TymeDigital Vietnam. All rights reserved.
//

import UIKit
import SwiftUI

public class TymeXDatePickerView: TymeXBaseView {
    // MARK: - IBOutlets
    @IBOutlet weak private(set) var containerView: UIView!
    @IBOutlet public weak var datePickerView: TymeXCalendarPickerView!

    // MARK: - Properties
    let highlightedView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    let calendarPicker: TymeXCalendarPickerView = {
        return TymeXCalendarPickerView()
    }()
    public var valueChange: ((TymeXDateComponent) -> Void)?

    // MARK: - Initial
    open override func initView() {
        super.initView()
        containerView.frame = bounds
        addSubview(containerView)
        configUIs()
    }

    // MARK: - Privates
    private func configUIs() {
        datePickerView.delegate = self
        highlightedView.translatesAutoresizingMaskIntoConstraints = false
        datePickerView.addSubview(highlightedView)

        changeHighlightColor(.gray)

        datePickerView.dateFormatType = .default
        datePickerView.minimumDate = Calendar.current.date(byAdding: .year, value: -1000, to: Date())
        datePickerView.maximumDate = Calendar.current.date(byAdding: .year, value: 1000, to: Date())
        datePickerView.localeType = .enLocale

        datePickerView.selectFont = SmokingCessation.fontSFProTextSemiBold16
        datePickerView.selectTextColor = SmokingCessation.colorPrimary100

        datePickerView.font = SmokingCessation.fontSFProTextRegular16
        datePickerView.textColor = SmokingCessation.colorTextDefault
    }

    private func changeHighlightColor(_ color: UIColor) {
        if let bgView = self.datePickerView.subviews.first?.subviews,
           bgView.count >= 2 {
            bgView[1].alpha = 0
            NSLayoutConstraint.activate([
                highlightedView.heightAnchor.constraint(equalTo: bgView[1].heightAnchor),
                highlightedView.leadingAnchor.constraint(
                    equalTo: datePickerView.leadingAnchor, constant: 24
                ),
                highlightedView.trailingAnchor.constraint(
                    equalTo: datePickerView.trailingAnchor, constant: -24
                ),
                highlightedView.centerYAnchor.constraint(equalTo: bgView[1].centerYAnchor)
            ])
            highlightedView.layer.cornerRadius = bgView[1].frame.size.height/2
        }
        highlightedView.backgroundColor = color
        datePickerView.sendSubviewToBack(highlightedView)
    }
}

extension TymeXDatePickerView: TymeXCalendarPickerDelegate {
    public func calendarPickerSelectDate(_ dateComponent: TymeXDateComponent) {
        valueChange?(dateComponent)
    }
}
