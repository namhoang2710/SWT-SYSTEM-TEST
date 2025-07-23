//
//  TymeXItemNavigationalCell.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 11/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public final class TymeXItemNavigationalCell: TymeXTransactionCell {
    override func updateUI() {
        rightIconImageView.isHidden = false
        contentLabel.isHidden = true
    }

    public override func configTitleLabel() {
        if let titleColor = model?.titleColor {
            titleLabel.attributedText = NSAttributedString(
                string: model?.title ?? "",
                attributes: SmokingCessation.textBodyDefaultL.color(titleColor)
            )
            titleLabel.lineBreakMode = .byTruncatingTail
        }
    }
}
