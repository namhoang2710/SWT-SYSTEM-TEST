//
//  ActionCardSheetContainerController.swift
//  TymeComponent
//
//  Created by Tuan Pham on 19/04/2022.
//

import UIKit

public class TymeXActionCardSheetContainerController: UIViewController, TymeXCardSheetConfigurable {

    public let contentController: TymeXActionCardSheetPresentable.CardSheetLayoutType
    public let parentController: UIViewController

    internal var runningAnimations: [UIViewPropertyAnimator] = []
    internal var presentationState: PresentationState = .shortForm
    internal var animationProgressWhenInterrupted: CGFloat = .zero

    internal var presentable: TymeXActionCardSheetPresentable {
        return contentController
    }

    init(contentController: TymeXActionCardSheetPresentable.CardSheetLayoutType,
         parentController: UIViewController) {

        self.contentController = contentController
        self.parentController = parentController

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    struct Constants {
        static let indicatorYOffset = CGFloat(8.0)
        static let snapMovementSensitivity = CGFloat(0.8)
        static let dragIndicatorSize = CGSize(width: 200, height: 48)
    }

    private(set) lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPanOnContainerView(_:)))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()

    private(set) lazy var mainContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        return stackView
    }()

    private(set) lazy var contentContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        return stackView
    }()

    private(set) lazy var dragIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = presentable.mxDragIndicatorBackgroundColor
        view.layer.cornerRadius = Constants.dragIndicatorSize.height / 2.0
        return view
    }()

    private(set) lazy var indicatorContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private(set) lazy var visualEffectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView()
        return effectView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
//
//        presentable.moveToShortForm = { [weak self] in
//            self?.transision(to: .shortForm, duration: 0.7)
//        }
//
//        presentable.moveToLongForm = { [weak self] in
//            self?.transision(to: .longForm, duration: 0.7)
//        }
    }

    public override func viewDidLayoutSubviews() {

        if presentable.mxShouldRoundTopCorners {
            contentContainerStackView.mxAddCorners(
                corners: [.topLeft, .topRight],
                radius: presentable.mxCornerRadius
            )
        }

        presentable.cardSheetNavigationView.setNeedsLayout()

        super.viewDidLayoutSubviews()
    }

    @discardableResult
    internal func present() -> TymeXActionCardSheetContainerController {
        view.frame = .init(
            x: .zero,
            y: mxCardSheetShortFormYPos,
            width: parentController.view.bounds.width,
            height: mxCardSheetLongFormValue
        )
        view.layoutIfNeeded()
        return self
    }
}
