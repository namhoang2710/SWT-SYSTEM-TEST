//
//  PaddedUILabel.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

/// Custom UILabel that allow adding insets to match or workaround with the design
class PaddedUILabel: UILabel {
    init(padding: UIEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)) {
        super.init(frame: .zero)
        self.padding = padding
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var padding = UIEdgeInsets()

    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
}
