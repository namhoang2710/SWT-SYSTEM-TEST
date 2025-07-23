//
//  TymeXBaseView.swift
//  SmartApp
//
//  Created by Ngoc Truong on 10/23/20.
//  Copyright © 2020 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

open class TymeXBaseView: UIView {

    // Outlets
    @IBOutlet public weak var contentView: UIView!

    public override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    open func commonInit() {
        guard let viewFromNib = loadViewFromNib() else { return }
        self.contentView = viewFromNib

        // Make the view stretch with containing view
        self.contentView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth.union(.flexibleHeight)

        // Adding custom subview on top of our view (over any custom drawing > see note below)
        self.addSubview(self.contentView)
        contentView.fixInView(self)
        initView()
    }

    open func getIdentityView() -> String {
        return "\(type(of: self))"
    }

    open func initView() {
        // to override if needed
    }

    open func loadViewFromNib() -> UIView? {
        guard let nibName = self.nibFileName() else { return nil }
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)

        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView

        return view
    }

    open func nibFileName() -> String? {
        return NSStringFromClass(self.classForCoder).components(separatedBy: ".").last
    }
}
