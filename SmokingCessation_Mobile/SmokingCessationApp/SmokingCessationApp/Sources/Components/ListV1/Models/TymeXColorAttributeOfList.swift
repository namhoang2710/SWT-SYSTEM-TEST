//
//  TymeXColorAttributeOfList.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 13/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public class TymeXColorAttributeOfList {
    var key: TymeXListItemCustomizeKeys
    var value: UIColor

    public init(
        key: TymeXListItemCustomizeKeys,
        value: UIColor
    ) {
        self.key = key
        self.value = value
    }
}
