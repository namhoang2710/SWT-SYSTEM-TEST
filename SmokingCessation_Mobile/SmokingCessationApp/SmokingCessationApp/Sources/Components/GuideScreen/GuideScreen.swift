//
//  GuideScreen.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit
import Lottie

open class GuideScreen: UIViewController, UIGestureRecognizerDelegate {
    var scrollViewHeightConstraint: NSLayoutConstraint?
    var isShowDragIndicator = true
    var topContentView: GuideScreenTopView
    var guideScreenType: GuideScreenType?
    var mainContentType: GuideScreenMainViewType?
    var isTopLinePresented: Bool
    var isBottomLinePresented: Bool
    var onLeftCompletion: TymeXCompletion?
    var onRightCompletion: TymeXCompletion?
    var topPictogramView: UIView?
    var buttonDock: ButtonDock?
    var titleAndSubtitleStackView: UIStackView?
    var topTitleLabel = UILabel()
    var topSubTitleLabel = UILabel()
    var iconListView: IconListView?
    var stepListView: StepListView?
    var customSlotView: UIView?
    var customSlotConstraints: [NSLayoutConstraint] = []
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.accessibilityIdentifier = "scrollViewTymeXGuideScreen"
        return scrollView
    }()

    public init(
        leftCompletion: TymeXCompletion? = nil,
        rightCompletion: TymeXCompletion? = nil,
        topContentView: GuideScreenTopView,
        guideScreenType: GuideScreenType = .fullScreen,
        mainContentType: GuideScreenMainViewType,
        isTopLinePresented: Bool = false,
        isBottomLinePresented: Bool = false,
        buttonDock: ButtonDock,
        customSlotView: UIView? = nil
    ) {
        self.onLeftCompletion = leftCompletion
        self.onRightCompletion = rightCompletion
        self.topContentView = topContentView
        self.guideScreenType = guideScreenType
        self.mainContentType = mainContentType
        self.isTopLinePresented = isTopLinePresented
        self.isBottomLinePresented = isBottomLinePresented
        self.buttonDock = buttonDock
        self.customSlotView = customSlotView
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // setup views
        setupViews()
    }

    private func ensureLayoutIsUpToDate() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        scrollView.layoutIfNeeded()
      }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ensureLayoutIsUpToDate()
    }

    public override func viewDidLayoutSubviews() {
       super.viewDidLayoutSubviews()

       guard guideScreenType == .modal else { return }

       scrollView.layoutIfNeeded()
       let contentH = scrollView.contentSize.height

       // Compute how much vertical space is truly available
       let dockHeight: CGFloat = buttonDock?.bounds.height ?? 0
       let safeTopInset = view.safeAreaInsets.top
       let safeBottomInset = view.safeAreaInsets.bottom

       // available = screenHeight – safeTop – safeBottom – topOffset – dockHeight
       let maxH = view.bounds.height
                - safeTopInset
                - safeBottomInset
                - dockHeight

       // Cap scrollView’s height constraint
       let finalH = min(contentH, maxH)
       scrollViewHeightConstraint?.constant = finalH

       // Enable scrolling if the content actually overflows
       let needsScroll = contentH > maxH
       scrollView.isScrollEnabled      = needsScroll
       scrollView.alwaysBounceVertical = needsScroll
     }

    // MARK: - Constant
    struct ConstantsGuideScreen {
        static let stepperTopLineHeight: CGFloat = 16
        static let stepperLineWidth: CGFloat  = 2
        static let stepNumberCircleSize: CGFloat  = 24
    }
}

