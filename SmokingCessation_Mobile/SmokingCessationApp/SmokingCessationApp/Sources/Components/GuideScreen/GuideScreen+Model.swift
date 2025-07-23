//
//  GuideScreen+Model.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

// MARK: - Structures for Content of Guideline

/// A public structure configuring the content in case of using step guideline
public struct StepGuidelineContent {
    public var title: String
    public var subTitle: String?
    public var isTitleHighlighted: Bool
    public init(title: String, subTitle: String? = nil, isTitleHighlighted: Bool = false) {
        self.title = title
        self.subTitle = subTitle
        self.isTitleHighlighted = isTitleHighlighted
    }
}

/// A public structure configuring the content in case of using icon guideline
public struct IconGuidelineContent {
    public var title: String
    public var subTitle: String?
    public var icon: UIImage
    public var isTitleHighlighted: Bool
    public init(title: String, subTitle: String? = nil, icon: UIImage, isTitleHighlighted: Bool = false) {
        self.title = title
        self.subTitle = subTitle
        self.icon = icon
        self.isTitleHighlighted = isTitleHighlighted
    }
}

/// A class defining the layout of the top view of the guide screen
public class GuideScreenTopView {
    public var topPictogramView: UIView
    public var title: String
    public var subTitle: String?
    public init(topPictogramView: UIView, title: String, subTitle: String? = nil) {
        self.topPictogramView = topPictogramView
        self.title = title
        self.subTitle = subTitle
    }
}
