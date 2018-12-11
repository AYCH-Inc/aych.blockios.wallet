//
//  KYCTierCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

class KYCTierCell: KYCCell {
    
    // MARK: Private Static Properties
    
    static fileprivate let headlineContainerHeight: CGFloat = 50.0
    static fileprivate let stackviewInteritemPadding: CGFloat = 12.0
    static fileprivate let stackviewVerticalPadding: CGFloat = 40.0
    static fileprivate let stackviewLeadingPadding: CGFloat = 24.0
    static fileprivate let stackviewTrailingPadding: CGFloat = 8.0
    static fileprivate let disclosureTrailingPadding: CGFloat = 24.0
    static fileprivate let disclosureButtonWidth: CGFloat = 56.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var disclosureButton: UIButton!
    @IBOutlet fileprivate var headlineContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var headlineContainerView: GradientView!
    @IBOutlet fileprivate var headlineDescription: UILabel!
    @IBOutlet fileprivate var tierDescription: UILabel!
    @IBOutlet fileprivate var limitAmountDescription: UILabel!
    @IBOutlet fileprivate var limitTimeframe: UILabel!
    @IBOutlet fileprivate var limitDurationEstimate: UILabel!
    @IBOutlet fileprivate var tierApprovalStatus: UILabel!
    
    // MARK: Private Properties
    
    fileprivate var tapActionBlock: KYCCellModel.Action?
    
    // MARK: Actions
    
    @IBAction func disclosureButtonTapped(_ sender: UIButton) {
        tapActionBlock?()
    }
    
    // MARK: Overrides
    
    override func configure(with model: KYCCellModel) {
        guard case let .tier(payload) = model else { return }
        tapActionBlock = payload.action
        
        disclosureButton.layer.cornerRadius = disclosureButton.bounds.width / 2.0
        disclosureButton.layer.borderWidth = 1.0
        disclosureButton.layer.borderColor = UIColor(red:0.8, green:0.86, blue:0.9, alpha:1).cgColor
        
        let tier = payload.tier
        
        layer.cornerRadius = 4.0
        if let headline = tier.headline {
            headlineDescription.text = headline
        }
        
        tierDescription.text = tier.tierDescription
        limitAmountDescription.text = tier.limitDescription
        limitTimeframe.text = tier.limitTimeframe
        limitDurationEstimate.text = tier.duration
        
        let headlineContainerHeight = tier.headline != nil ? KYCTierCell.headlineContainerHeight : 0.0
        guard headlineContainerHeightConstraint.constant != headlineContainerHeight else { return }
        
        headlineContainerHeightConstraint.constant = headlineContainerHeight
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override class func heightForProposedWidth(_ width: CGFloat, model: KYCCellModel) -> CGFloat {
        guard case let .tier(payload) = model else { return 0.0 }
        let tier = payload.tier
        
        let headlineContainerHeight = tier.headline != nil ? KYCTierCell.headlineContainerHeight : 0.0
        let widthPadding = disclosureButtonWidth + stackviewLeadingPadding + stackviewTrailingPadding + disclosureTrailingPadding
        let adjustedWidth = width - widthPadding
        
        let tierDescriptionHeight = NSAttributedString(
            string: tier.tierDescription,
            attributes: [.font: headlineFont()]).heightForWidth(width: adjustedWidth)
        
        let limitAmountHeight = NSAttributedString(
            string: tier.limitDescription,
            attributes: [.font: limitFont()]).heightForWidth(width: adjustedWidth)
        
        let timeframeHeight = NSAttributedString(
            string: tier.limitTimeframe,
            attributes: [.font: timeframeFont()]).heightForWidth(width: adjustedWidth)
        
        let durationEstimateHeight = NSAttributedString(
            string: tier.tierDescription,
            attributes: [.font: timeframeFont()]).heightForWidth(width: adjustedWidth)
        
        let labelHeights = headlineContainerHeight + tierDescriptionHeight + limitAmountHeight + timeframeHeight + durationEstimateHeight
        
        return labelHeights + stackviewInteritemPadding + stackviewVerticalPadding
    }
    
    static func headlineFont() -> UIFont {
        let font = Font(.branded(.montserratBold), size: .custom(14.0))
        return font.result
    }
    
    static func limitFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(32.0))
        return font.result
    }
    
    static func timeframeFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(14.0))
        return font.result
    }
}
