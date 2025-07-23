//
//  CustomDecimalKeyboardDelegate.swift
//  TymeXUIComponent
//
//  Created by Thao Lai on 15/03/2024.
//  Copyright © 2024 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

public protocol CustomDecimalKeyboardDelegate: AnyObject, UIKeyInput, UITextInput {
    func shouldChangeCharacters(in range: NSRange, replacementString string: String) -> Bool
    func handleCustomeKeyboardDeleteKey()
}
