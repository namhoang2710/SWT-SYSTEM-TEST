//
//  InputHelperMessageContent.swift
//  TymeXUIComponent
//
//  Created by Vuong Tran on 01/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

public enum TymeXInputHelperMessageContent {
    case text(String?)
    case limitCharacterCount(Int)
}

public final class TymeXInputHelperMessage {
    private var content: TymeXInputHelperMessageContent?
    var currentCharacterCount: Int?

    public init(content: TymeXInputHelperMessageContent? = nil) {
        self.content = content
    }

    var shouldReloadHelperMessageOnTextChange: Bool {
        switch content {
        case .none, .text:
            return false
        case .limitCharacterCount:
            return true
        }
    }

    func setContent(_ content: TymeXInputHelperMessageContent) {
        self.content = content
    }

    func makeText() -> String? {
        switch content {
        case .none:
            return nil
        case .text(let string):
            return string
        case .limitCharacterCount(let limitCharacter):
            guard limitCharacter > 0 else { return nil }
            return "\(currentCharacterCount ?? 0)/\(limitCharacter)"
        }
    }
}
