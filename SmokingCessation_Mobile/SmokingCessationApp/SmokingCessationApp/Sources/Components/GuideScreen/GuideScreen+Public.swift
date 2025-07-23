//
//  GuideScreen+Public.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 20/6/25.
//

import Foundation
import UIKit

public extension GuideScreen {
    func getTopTitleLabel() -> UILabel {
        return topTitleLabel
    }

    func getTopSubTitleLabel() -> UILabel {
        return topSubTitleLabel
    }

    /// Get all the titles of the guideline content
    /// - Returns: A list of UILabels
    func getAllGuidelineContentTitleLabel() -> [UILabel]? {
        guard let mainContentType = mainContentType else { return nil }
        switch mainContentType {
        case .icon(let iconContents):
            if let iconListView = iconListView {
                let cell = iconListView.iconListCellView
                return cell.map { $0.guideLineContent!.titleLabel }
            }
        case .step(let stepContents):
            if let stepListView = stepListView {
                let cell = stepListView.stepListCellView
                return cell.map { $0.guideLineContent!.titleLabel }
            }
        }
        return nil
    }

    /// Get guideline content label at a specific index
    /// - Parameter index: index position
    /// - Returns: a UILabel
    func getGuidelineContentTitleLabel(at index: Int) -> UILabel? {
        guard let mainContentType = mainContentType else { return nil }
        switch mainContentType {
        case .icon(let iconContents):
            if let iconListView = iconListView {
                let cell = iconListView.iconListCellView[index]
                return cell.guideLineContent!.getTitleLabel()
            }
        case .step(let stepContents):
            if let stepListView = stepListView {
                let cell = stepListView.stepListCellView[index]
                return cell.guideLineContent!.getTitleLabel()
            }
        }
        return nil
    }

    /// Get all the subtitles of the guideline content
    /// - Returns: A list of UILabels
    func getAllGuidelineContentSubTitleLabel() -> [UILabel]? {
        guard let mainContentType = mainContentType else { return nil }
        switch mainContentType {
        case .icon(let iconContents):
            if let iconListView = iconListView {
                let cell = iconListView.iconListCellView
                return cell.map { $0.guideLineContent!.subTitleLabel }
            }
        case .step(let stepContents):
            if let stepListView = stepListView {
                let cell = stepListView.stepListCellView
                return cell.map { $0.guideLineContent!.subTitleLabel }
            }
        }
        return nil
    }

    /// Get sub title label of the guideline content at a specific index
    /// - Parameter index: index position
    /// - Returns: A UILabel
    func getGuidelineContentSubTitleLabel(at index: Int) -> UILabel? {
        guard let mainContentType = mainContentType else { return nil }
        switch mainContentType {
        case .icon(let iconContents):
            if let iconListView = iconListView {
                let cell = iconListView.iconListCellView[index]
                return cell.guideLineContent!.getSubTitleLabel()
            }
        case .step(let stepContents):
            if let stepListView = stepListView {
                let cell = stepListView.stepListCellView[index]
                return cell.guideLineContent!.getSubTitleLabel()
            }
        }
        return nil
    }
}

