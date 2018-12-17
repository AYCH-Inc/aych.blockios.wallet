//
//  KYCTierCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

protocol KYCTierCellDelegate: class {
    func tierCell(_ cell: KYCTierCell, selectedTier: KYCTier)
}

class KYCTierCell: UICollectionViewCell {
    
    // MARK: Public Properties
    
    weak var delegate: KYCTierCellDelegate?
    
    // MARK: Private Static Properties
    
    static fileprivate let headlineContainerHeight: CGFloat = 50.0
    static fileprivate let stackviewInteritemPadding: CGFloat = 4.0
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
    @IBOutlet fileprivate var tierRequirements: UILabel!
    @IBOutlet fileprivate var shadowView: UIView!
    
    fileprivate var allLabels: [UILabel] {
        return [headlineDescription,
        tierDescription,
        limitAmountDescription,
        limitTimeframe,
        limitDurationEstimate,
        tierApprovalStatus]
    }
    
    // MARK: Private Properties
    fileprivate var model: KYCTierCellModel!
    fileprivate var tier: KYCTier {
        return model.tier
    }
    
    // MARK: Actions
    
    @IBAction func disclosureButtonTapped(_ sender: UIButton) {
        guard model.status == .none else { return }
        delegate?.tierCell(self, selectedTier: tier)
    }
    
    // MARK: Overrides
    
    func configure(with model: KYCTierCellModel) {
        self.model = model
        layer.cornerRadius = 8.0
        layer.masksToBounds = false
        disclosureButton.setImage(model.status.image, for: .normal)
        disclosureButton.layer.cornerRadius = disclosureButton.bounds.width / 2.0
        disclosureButton.layer.borderWidth = 1.0
        disclosureButton.layer.borderColor = model.status.color?.cgColor
        
        let tier = model.tier
        
        if model.status == .rejected {
            styleAsDisabled()
        } else {
            setupShadowView()
        }
        
        tierRequirements.isHidden = model.requirementsVisibility.isHidden
        tierRequirements.text = model.tier.requirementsDescription
        
        tierApprovalStatus.isHidden = model.statusVisibility.isHidden
        tierApprovalStatus.text = model.status.description
        tierApprovalStatus.textColor = model.status.color
        
        headlineDescription.isHidden = (tier.headline == nil || model.status == .rejected)
        if let headline = tier.headline {
            headlineDescription.text = headline.uppercased()
        }
        
        let attributedTierDescription = NSAttributedString(
            string: tier.tierDescription.uppercased(),
            attributes: [.font: KYCTierCell.headlineFont(),
                         .kern: NSNumber(value: 4.0)]
        )
        
        tierDescription.attributedText = attributedTierDescription
        limitAmountDescription.text = tier.limitDescription
        limitTimeframe.text = tier.limitTimeframe
        limitDurationEstimate.text = tier.duration
        
        let headlineContainerHeight = model.headlineContainerVisibility.isHidden ? 0.0 : KYCTierCell.headlineContainerHeight
        guard headlineContainerHeightConstraint.constant != headlineContainerHeight else { return }
        
        headlineContainerHeightConstraint.constant = headlineContainerHeight
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    fileprivate func setupShadowView() {
        shadowView.layer.cornerRadius = 4.0
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowRadius = 4.0
        shadowView.layer.shadowColor = UIColor(
            red: 0.87,
            green: 0.87,
            blue: 0.87,
            alpha:1
            ).cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
        shadowView.layer.shadowOpacity = 1.0
    }
    
    fileprivate func styleAsDisabled() {
        allLabels.forEach({
            $0.textColor = .disabled
            $0.alpha = 1
        })
        layer.borderColor = UIColor.disabled.cgColor
        layer.borderWidth = 1.0
        disclosureButton.setImage(#imageLiteral(resourceName: "icon_lock"), for: .normal)
        disclosureButton.isEnabled = false
        disclosureButton.layer.borderColor = UIColor.disabled.cgColor
    }
    
    class func heightForProposedWidth(_ width: CGFloat, model: KYCTierCellModel) -> CGFloat {
        let tier = model.tier
        
        let headlineContainerHeight = model.headlineContainerVisibility.isHidden ? 0.0 : KYCTierCell.headlineContainerHeight
        let widthPadding = disclosureButtonWidth + stackviewLeadingPadding + stackviewTrailingPadding + disclosureTrailingPadding
        let adjustedWidth = width - widthPadding
        
        let tierDescriptionHeight = NSAttributedString(
            string: tier.tierDescription,
            attributes: [.font: headlineFont(),
                         .kern: NSNumber(value: 4.0)]).heightForWidth(width: adjustedWidth)
        
        let limitAmountHeight = NSAttributedString(
            string: tier.limitDescription,
            attributes: [.font: limitFont()]).heightForWidth(width: adjustedWidth)
        
        let timeframeHeight = NSAttributedString(
            string: tier.limitTimeframe,
            attributes: [.font: timeframeFont()]).heightForWidth(width: adjustedWidth)
        
        let durationEstimateHeight = NSAttributedString(
            string: tier.tierDescription,
            attributes: [.font: timeframeFont()]).heightForWidth(width: adjustedWidth)
        
        var tierRequirementsHeight = NSAttributedString(
            string: tier.requirementsDescription,
            attributes: [.font: requirementsFont()]).heightForWidth(width: adjustedWidth)
        
        var statusHeight: CGFloat = 0.0
        if let value = model.status.description {
            statusHeight = NSAttributedString(
                string: value,
                attributes: [.font: timeframeFont()]).heightForWidth(width: adjustedWidth)
        }
        
        statusHeight = model.statusVisibility.isHidden ? 0.0 : statusHeight
        tierRequirementsHeight = model.requirementsVisibility.isHidden ? 0.0 : tierRequirementsHeight
        
        let numberVisible = [tierDescriptionHeight,
                             limitAmountHeight,
                             timeframeHeight,
                             durationEstimateHeight,
                             tierRequirementsHeight,
                             statusHeight].filter({ $0 > 0.0}).count
        
        let stackviewPadding = CGFloat((numberVisible - 1)) * stackviewInteritemPadding
        
        let labelHeights = headlineContainerHeight +
            tierDescriptionHeight +
            limitAmountHeight +
            timeframeHeight +
            durationEstimateHeight +
            tierRequirementsHeight
        
        return labelHeights + stackviewPadding + stackviewVerticalPadding
    }
    
    fileprivate static func headlineFont() -> UIFont {
        let font = Font(.branded(.montserratBold), size: .custom(14.0))
        return font.result
    }
    
    fileprivate static func limitFont() -> UIFont {
        let font = Font(.branded(.montserratSemiBold), size: .custom(32.0))
        return font.result
    }
    
    fileprivate static func timeframeFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(14.0))
        return font.result
    }
    
    fileprivate static func requirementsFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(14.0))
        return font.result
    }
}
