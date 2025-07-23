//
//  TymeXItemValueCell.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 11/11/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

public final class TymeXItemValueCell: TymeXTransactionCell {
    public override func configTitleLabel() {
        guard let model = model else { return }
        titleLabel.attributedText = NSAttributedString(
            string: model.title,
            attributes: SmokingCessation.textBodyDefaultL.color(model.titleColor)
        )
        titleLabel.lineBreakMode = .byTruncatingTail
    }
}
