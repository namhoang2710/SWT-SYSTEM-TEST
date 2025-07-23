//
//  CATransactionExt.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 26/10/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public extension CATransaction {
    /**
      Executes the provided `actions` closure wrapped in `CATransaction`.
      Optionally adds all the specific properties to commit the transaction with
      - Parameters:
        - duration: Duration of transaction
        - timingFunction: Specific timing function to use with transaction
        - disableActions: Wether actual animation should happen during transaction
        - actions: What to do while transaction is commited
        - completion: Closure to be executed when transaction is completes

      Example to disable animations for a specific change
      ```
      CATransaction.perform(disableActions: true) {
         view.frame = newFrame
      }
     */
    class func mxPerform(
        withDuration duration: TimeInterval? = nil,
        timingFunction: CAMediaTimingFunction? = nil,
        disableActions: Bool? = nil,
        actions: TymeXCompletion,
        completion: TymeXCompletion? = nil
    ) {
        CATransaction.begin()
        duration.map { CATransaction.setAnimationDuration($0) }
        timingFunction.map { CATransaction.setAnimationTimingFunction($0) }
        disableActions.map { CATransaction.setDisableActions($0) }
        completion.map { CATransaction.setCompletionBlock($0) }
        actions()
        CATransaction.commit()
    }
}
