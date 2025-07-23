//
//  ReactiveExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import RxSwift
import RxCocoa

extension Reactive where Base: BaseButton {
    /// Reactive wrapper for `TouchUpInside` control event.
    public var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
}
