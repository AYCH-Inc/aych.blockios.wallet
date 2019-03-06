//
//  KYCAvailableFundsHeaderView.swift
//  Blockchain
//
//  Created by AlexM on 12/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

/// You should only use `KYCAvailableFundsHeaderView` when the user has available funds to trade.
/// If they have zero funds you should still use this header but show `$0` for their available funds.
/// If they're not enrolled in a tier or `Swap` is unavailable, please use `KYCCTAHeaderView`.
class KYCAvailableFundsHeaderView: KYCTiersHeaderView {
    
    static let identifier: String = String(describing: KYCAvailableFundsHeaderView.self)
    
    // MARK: Private Static Properties
    
    fileprivate static let horizontalPadding: CGFloat = 32.0
    fileprivate static let amountStackViewPadding: CGFloat = 4.0
    fileprivate static let outerStackViewPadding: CGFloat = 32.0
    fileprivate static let dismissButtonHeight: CGFloat = 30.0
    fileprivate static let swapNowButtonHeight: CGFloat = 57.0
    
    /// The height when you suppress the chevron at the top of the header
    fileprivate static let suppressDismissalTopPadding: CGFloat = 32.0
    fileprivate static let dismissButtonVerticalPadding: CGFloat = 8.0
    fileprivate static let labelsToBottomPadding: CGFloat = 16.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var dismissButton: UIButton!
    @IBOutlet fileprivate var availableAmount: UILabel!
    @IBOutlet fileprivate var availabilityHeadline: UILabel!
    @IBOutlet fileprivate var availabilityDescription: UILabel!
    @IBOutlet fileprivate var stackViewToTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var stackViewToDismissButtonConstraint: NSLayoutConstraint!
    
    // MARK: Public Class Functions
    
    override func configure(with viewModel: KYCTiersHeaderViewModel) {
        availableAmount.text = viewModel.amount
        availabilityHeadline.text = viewModel.availabilityTitle
        availabilityDescription.text = viewModel.availabilityDescription
        
        dismissButton.isHidden = viewModel.suppressDismissCTA
        if viewModel.suppressDismissCTA, stackViewToDismissButtonConstraint.isActive {
            NSLayoutConstraint.deactivate([stackViewToDismissButtonConstraint])
            NSLayoutConstraint.activate([stackViewToTopConstraint])
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: Actions
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        delegate?.dismissButtonTapped(self)
    }
    
    // MARK: Overrides
    
    override class func estimatedHeight(for width: CGFloat, model: KYCTiersHeaderViewModel) -> CGFloat {
        var availableAmountHeight: CGFloat = 0.0
        
        let adjustedWidth = width - horizontalPadding
        if let value = model.amount {
            availableAmountHeight = NSAttributedString(
                string: value,
                attributes: [.font: availableAmountFont()]).heightForWidth(width: adjustedWidth)
        }
        
        var availabilityHeadlineHeight: CGFloat = 0.0
        var availabilityDescriptionHeight: CGFloat = 0.0
        
        if let availabilityTitle = model.availabilityTitle {
            availabilityHeadlineHeight = NSAttributedString(
                string: availabilityTitle,
                attributes: [.font: availabilityHeadlineFont()]).heightForWidth(width: adjustedWidth)
        }
        
        if let availabilityDescription = model.availabilityDescription {
            availabilityDescriptionHeight = NSAttributedString(
                string: availabilityDescription,
                attributes: [.font: availabilityDescriptonFont()]).heightForWidth(width: adjustedWidth)
        }
        
        let availabilityHeights = availabilityHeadlineHeight + availabilityDescriptionHeight + availableAmountHeight
        
        var topPadding: CGFloat = 0.0
        if model.suppressDismissCTA {
            topPadding = suppressDismissalTopPadding
        } else {
            topPadding = dismissButtonVerticalPadding + dismissButtonHeight
        }
        
        let padding = amountStackViewPadding + outerStackViewPadding + labelsToBottomPadding
        let result = availabilityHeights + padding + topPadding
        
        return result
    }
    
    // MARK: Fonts
    
    fileprivate class func availableAmountFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(48.0))
        return font.result
    }
    
    fileprivate class func availabilityHeadlineFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(17.0))
        return font.result
    }
    
    fileprivate class func availabilityDescriptonFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(15.0))
        return font.result
    }
}
