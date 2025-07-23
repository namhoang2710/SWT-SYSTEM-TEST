//
//  CardSheetContainer+Transision.swift
//  TymeComponent
//
//  Created by Tuan Pham on 20/04/2022.
//

import UIKit

extension TymeXActionCardSheetContainerController {

    @objc func didPanOnContainerView(_ recognizer: UIPanGestureRecognizer) {

//        let direction = recognizer.verticalDirection(target: view)
//
//        let shouldTransition = (direction == .down && presentationState == .longForm)
//        || (direction == .up && presentationState == .shortForm)

//        guard shouldTransition && shouldRespond(to: panGestureRecognizer) else { return }
//        guard shouldTransition else { return }
        switch recognizer.state {

        case .began:
            switch presentationState.nextState {
            case .shortForm:
                presentable.cardSheetStartMovingToShortForm()
            case .longForm:
                presentable.cardSheetStartMovingToLongForm()
            case .fitForm:
                presentable.cardSheetStartMovingToFitForm()
            }

            startTransition(state: presentationState.nextState, duration: 0.7)

        case .changed:
            let translation = recognizer.translation(in: contentController.view)
            var fractionComplete = translation.y / mxCardSheetLongFormValue
            fractionComplete = presentationState == .longForm ? fractionComplete : -fractionComplete
            updateTransition(fractionCompleted: fractionComplete)

        case .ended:
            continueTransition()

        default:
            break
        }
    }

    private func startTransition(state: PresentationState, duration: TimeInterval) {
          if runningAnimations.isEmpty {
              transision(to: state, duration: duration)
          }
          for animator in runningAnimations {
              animator.pauseAnimation()
              animationProgressWhenInterrupted = animator.fractionComplete
          }
      }

    private func continueTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }

    private func updateTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }

    public func moveToShortForm(duration: TimeInterval = 0.7) {
        presentable.cardSheetStartMovingToShortForm()
        transision(to: .shortForm, duration: duration)
    }

    public func moveToLongForm(duration: TimeInterval = 0.7) {
        presentable.cardSheetStartMovingToLongForm()
        transision(to: .longForm, duration: duration)
    }

    public func moveToFitForm(duration: TimeInterval = 0.7) {
        presentable.cardSheetStartMovingToFitForm()
        transision(to: .fitForm, duration: duration)

        let navigationView = presentable.cardSheetNavigationView
        for subview in contentContainerStackView.subviews where subview == navigationView {
            subview.gestureRecognizers?.removeAll()
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func transision(to state: PresentationState, duration: TimeInterval) {

        guard runningAnimations.isEmpty else { return }
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
            guard let self = self else { return }
            let newOriginY: CGFloat
            switch state {
            case .longForm:
                newOriginY = self.mxCardSheetLongFormYPos

            case .shortForm:
                newOriginY = self.mxCardSheetShortFormYPos

            case .fitForm:
                newOriginY = self.mxCardSheetFitFormYPos
            }

            self.view.frame.origin.y = newOriginY
        }

        frameAnimator.addCompletion { [weak self] _ in
            guard let self = self else { return }
            self.presentationState = self.presentationState.nextState
            self.runningAnimations.removeAll()

            switch self.presentationState {
            case .shortForm:
                self.presentable.cardSheetMovedToShortForm()

            case .longForm:
                self.presentable.cardSheetMovedToLongForm()
            case .fitForm:
                self.presentable.cardSheetMovedToFitForm()
            }
        }

        frameAnimator.startAnimation()
        runningAnimations.append(frameAnimator)

        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
            guard let self = self, self.presentable.hasDimBackground else { return }
            switch state {
            case .longForm:
                self.visualEffectView.isHidden = false
                let blurEffect = UIBlurEffect(style: .dark)
                self.visualEffectView.effect = blurEffect
                self.visualEffectView.alpha = 0.75
            case .shortForm, .fitForm:
                self.visualEffectView.effect = nil
                self.visualEffectView.isHidden = true
            }
        }

        blurAnimator.startAnimation()
        runningAnimations.append(blurAnimator)
    }
}
