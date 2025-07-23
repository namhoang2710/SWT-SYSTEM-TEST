//
//  ButtonDockProtocol.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

/// A protocol that defines the required methods for a button dock in the TymeX application.
///
/// This protocol is intended to be adopted by any class that needs to implement the functionality
/// related to updating amounts, fees, and displaying error messages in the button dock interface.
public protocol ButtonDockProtocol: AnyObject {

    /// Updates the displayed amount after applying a fee.
    ///
    /// - Parameter amountAfterFeeValue: The amount to be displayed after the fee has been applied.
    func updateAmountAfterFee(amountAfterFeeValue: Double)

    /// Updates the fee value displayed with the specified model and text.
    ///
    /// - Parameters:
    ///   - feeModel: The model containing fee information to be displayed.
    ///   - textValue: The text value to be displayed alongside the fee.
    ///   - startStrikeThroughLocation: The starting index for the strike-through effect in the text.
    ///   - lengthStrikeThrough: The length of the strike-through effect.
    func updateFeeValueWithModel(
        feeModel: FeeModel,
        textValue: String,
        startStrikeThroughLocation: Int,
        lengthStrikeThrough: Int
    )

    /// Resets all values in the button dock to their default state.
    func resetValues()

    /// Retrieves the term label associated with the button dock.
    ///
    /// - Returns: A UILabel representing the term label.
    func getTermLabel() -> UILabel

    /// Retrieves the helper label associated with the button dock.
    ///
    /// - Returns: A UILabel representing the helper label.
    func getHelperLabel() -> UILabel

    /// Displays an error message in the button dock.
    ///
    /// - Parameters:
    ///   - message: The error message to be displayed.
    ///   - flag: A boolean indicating whether to show or hide the error message.
    func showErrorMessage(message: String, flag: Bool)

    /// Shows or hides the line view in the button dock.
    ///
    /// - Parameter flag: A boolean indicating whether to show (true) or hide (false) the line view.
    func showLineView(flag: Bool)
}
