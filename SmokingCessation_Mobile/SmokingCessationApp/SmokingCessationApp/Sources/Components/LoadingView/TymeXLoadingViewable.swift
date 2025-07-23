//
//  LoadingViewable.swift
//  SmartApp
//
//  Created by Son Teemo on 10/28/19.
//  Copyright © 2019 Tyme Digital. All rights reserved.
//

import UIKit

public protocol TymeXLoadingViewable {
    typealias LoadingInfo = (isShow: Bool, message: String)
    func mxShowOverlayLoadingView(duration: TimeInterval)
    func mxShowFullScreenLoadingView(duration: TimeInterval, lottieAnimationName: String, bundle: Bundle)
    func mxShowLoadingView(in view: UIView, duration: TimeInterval, lottieAnimationName: String, bundle: Bundle)
    func tymeXHideLoadingView()
    func tymeXHideLoadingViewInContainerView(containerView: UIView)
}

extension TymeXLoadingViewable where Self: UIViewController {
    public func mxShowOverlayLoadingView(duration: TimeInterval) {
        tymeXHideLoadingView()
        let tymeXLoadingView = TymeXLoadingView(frame: UIScreen.main.bounds)
        UIApplication.shared.mxKeyWindow?.addSubview(tymeXLoadingView)
        UIApplication.shared.mxKeyWindow?.bringSubviewToFront(tymeXLoadingView)

        if duration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.tymeXHideLoadingView()
            }
        }
    }

    public func mxShowFullScreenLoadingView(
        duration: TimeInterval,
        lottieAnimationName: String = SmokingCessation.loadingAnimation,
        bundle: Bundle = BundleSmokingCessation.bundle
    ) {
        tymeXHideLoadingView()
        let tymeXLoadingView = TymeXLoadingView(frame: UIScreen.main.bounds)
        UIApplication.shared.mxKeyWindow?.addSubview(tymeXLoadingView)
        UIApplication.shared.mxKeyWindow?.bringSubviewToFront(tymeXLoadingView)
        tymeXLoadingView.showAnimatedLoading(lottieAnimationName: lottieAnimationName, bundle: bundle)
        if duration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.tymeXHideLoadingView()
            }
        }
    }

    public func mxShowLoadingView(
        in containerView: UIView,
        duration: TimeInterval = 0,
        lottieAnimationName: String = SmokingCessation.loadingAnimation,
        bundle: Bundle = BundleSmokingCessation.bundle
    ) {
        tymeXHideLoadingViewInContainerView(containerView: containerView)
        let tymeXLoadingView = TymeXLoadingView(frame: containerView.bounds)
        containerView.addSubview(tymeXLoadingView)
        containerView.bringSubviewToFront(tymeXLoadingView)
        tymeXLoadingView.showAnimatedLoading(lottieAnimationName: lottieAnimationName, bundle: bundle)
        if duration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.tymeXHideLoadingViewInContainerView(containerView: containerView)
            }
        }
    }

    public func tymeXHideLoadingView() {
        let defaultSubviews = UIApplication.shared.mxKeyWindow?.subviews ?? []
        for item in self.view.window?.subviews ?? defaultSubviews
        where item.isKind(of: TymeXLoadingView.self) {
            item.removeFromSuperview()
        }
    }

    public func tymeXHideLoadingViewInContainerView(containerView: UIView) {
        for item in containerView.subviews
        where item.isKind(of: TymeXLoadingView.self) {
            item.removeFromSuperview()
        }
    }

    public func tymeXBringLoadingViewToFront() {
        for item in UIApplication.shared.mxKeyWindow?.subviews ?? []
        where item.isKind(of: TymeXLoadingView.self) {
            UIApplication.shared.mxKeyWindow?.bringSubviewToFront(item)
        }
    }
}
