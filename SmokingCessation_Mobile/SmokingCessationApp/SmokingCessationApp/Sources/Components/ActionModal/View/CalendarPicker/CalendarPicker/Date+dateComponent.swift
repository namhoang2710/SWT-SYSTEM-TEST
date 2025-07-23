//
//  Date+dateComponent.swift
//  GoTymeApp
//
//  Created by Vinh Pham on 22/06/2022.
//  Copyright © 2022 TymeDigital Vietnam. All rights reserved.
//
import Foundation

extension Date {
    var mxDateComponent: TymeXDateComponent {
        var component = TymeXDateComponent()
        let calendar = Calendar.current
        component.year = (calendar as NSCalendar).components(.year, from: self).year ?? 0
        component.month = (calendar as NSCalendar).components(.month, from: self).month ?? 0
        component.day = (calendar as NSCalendar).components(.day, from: self).day ?? 0
        component.hour = (calendar as NSCalendar).components(.hour, from: self).hour ?? 0
        component.minute = (calendar as NSCalendar).components(.minute, from: self).minute ?? 0
        component.second = (calendar as NSCalendar).components(.second, from: self).second ?? 0
        return component
    }
}
