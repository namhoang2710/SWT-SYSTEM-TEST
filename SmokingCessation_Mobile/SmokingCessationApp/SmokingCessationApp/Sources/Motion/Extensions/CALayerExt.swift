//
//  CALayerExt.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 25/10/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public extension CALayer {
    class func mxAnimate(
        _ animation: TymeXCompletion,
        completion: TymeXCompletion? = nil
    ) {
        CATransaction.begin()
        if let completion = completion {
            CATransaction.setCompletionBlock { completion() }
        }
        animation()
        CATransaction.commit()
    }
}

public extension CALayer {
    var mxCurrentMediaTime: CFTimeInterval {
        return convertTime(CACurrentMediaTime(), from: nil)
    }
}
