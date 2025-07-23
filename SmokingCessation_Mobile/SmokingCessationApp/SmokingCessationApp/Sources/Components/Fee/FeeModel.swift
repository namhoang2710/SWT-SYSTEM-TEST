//
//  FeeModel.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

public enum FeeType: String {
    case additionalFee
    case fee
    case amountAfterFee
    case none
}

public class FeeModel {
    public var feeName: String = ""
    public var feeIcon: UIImage?
    public var feeValue: Double = 0
    public var isStrikeThrough: Bool = false
    public var description: String = ""
    public var type: FeeType = .none
    public init(
        feeName: String,
        feeIcon: UIImage? = nil,
        feeValue: Double = 0,
        isStrikeThrough: Bool = false,
        description: String = "",
        type: FeeType) {
        self.feeName = feeName
        self.feeIcon = feeIcon
        self.feeValue = feeValue
        self.isStrikeThrough = isStrikeThrough
        self.description = description
        self.type = type
    }
}
