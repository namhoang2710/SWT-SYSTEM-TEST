//
//  SelectionCard+Public.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 17/6/25.
//

import Foundation
import UIKit

extension SelectionCard {
    /// Get the internal model of the selection card
    public func getSelectionCardModel() -> SelectionCardModel {
        return model
    }

    /// Get title label of the predefined top slot for customization
    public func getTitleLabel() -> UILabel {
        return titleLabel
    }

    /// Configuring input model
    /// Selection card layout is configured based on `TymeXSelectionCardModel`
    /// - Parameter model: inputted model of type ``TymeXSelectionCardModel``
    public func configure(with model: SelectionCardModel) {
        switch model.topSlotOption {
        case .predefined(let predefinedSlot):
            setupSlot(with: .predefined(predefinedSlot))
        case .custom(let uiView):
            setupSlot(with: .custom(uiView))
        }
    }

    /// Configures the constraints for `slotContentContainerView`, `checkboxContainerView`, and`customTopSlotView`.
    ///
    /// This method allows FTs to define custom constraints for these views as needed.
    /// Only the first two views are guaranteed to be non-optional; the `customTopSlotView`
    /// is optional and will be passed as `nil` if not available.
    ///
    /// - Parameter combinedConstraints: A closure that receives:
    ///     - `slotContentContainerView`: The main content view.
    ///     - `checkboxContainerView`: The checkbox container view.
    ///     - `customTopSlotView`: An optional view for custom top slot constraints.
    public func configureConstraints(
        using combinedConstraints: (UIView, UIView, UIView?) -> Void
    ) {
        NSLayoutConstraint.deactivate(customTopSlotConstraints)
        if let customView = customTopSlotView {
            slotContentContainerView.addSubview(customView)
        }
        combinedConstraints(slotContentContainerView, checkboxContainerView, customTopSlotView)
    }
}
