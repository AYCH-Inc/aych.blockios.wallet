//
//  KYCTiersHeaderView.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit
import PlatformUIKit

protocol KYCTiersHeaderViewDelegate: class {
    func headerView(_ view: KYCTiersHeaderView, actionTapped: KYCTiersHeaderViewModel.Action)
    func dismissButtonTapped(_ view: KYCTiersHeaderView)
}

class KYCTiersHeaderView: UICollectionReusableView {
    
    static let identifier: String = String(describing: KYCTiersHeaderView.self)
    
    // MARK: Private Static Properties
    
    fileprivate static let horizontalPadding: CGFloat = 48.0
    fileprivate static let CTAHeight: CGFloat = 50.0
    fileprivate static let CTAInteritemPadding: CGFloat = 16.0
    fileprivate static let CTABottomPadding: CGFloat = 8.0
    fileprivate static let labelsToCTAPadding: CGFloat = 16.0
    fileprivate static let labelsInteritemPadding: CGFloat = 4.0
    fileprivate static let dismissButtonHeight: CGFloat = 30.0
    fileprivate static let dismissButtonVerticalPadding: CGFloat = 8.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var availableAmount: UILabel!
    @IBOutlet fileprivate var headline: UILabel!
    @IBOutlet fileprivate var swapLimitDescription: UILabel!
    @IBOutlet fileprivate var swapNowButton: UIButton!
    @IBOutlet fileprivate var learnMoreButton: UIButton!
    @IBOutlet fileprivate var contactSupportButton: UIButton!
    @IBOutlet fileprivate var dismissButton: UIButton!
    
    fileprivate var CTAs: [UIButton] {
        return [swapNowButton, learnMoreButton, contactSupportButton]
    }
    
    // MARK: Public
    
    weak var delegate: KYCTiersHeaderViewDelegate?
    
    // MARK: Public Functions
    
    func configure(with viewModel: KYCTiersHeaderViewModel) {
        availableAmount.isHidden = viewModel.availableAmount == nil
        availableAmount.text = viewModel.availableAmount
        headline.text = viewModel.headline
        swapLimitDescription.text = viewModel.description
        if let actions = viewModel.actions {
            swapNowButton.isHidden = actions.contains(.swapNow) == false
            learnMoreButton.isHidden = actions.contains(.learnMore) == false
            contactSupportButton.isHidden = actions.contains(.contactSupport) == false
        } else {
            CTAs.forEach({ $0.isHidden = true })
        }
        
        CTAs.forEach { button in
            button.layer.cornerRadius = 4.0
        }
        contactSupportButton.layer.borderWidth = 1.0
        contactSupportButton.layer.borderColor = UIColor.brandSecondary.cgColor
        
        swapNowButton.setTitle(LocalizationConstants.KYC.swapNow, for: .normal)
        learnMoreButton.setTitle(LocalizationConstants.ObjCStrings.BC_STRING_LEARN_MORE, for: .normal)
        contactSupportButton.setTitle(LocalizationConstants.KYC.contactSupport, for: .normal)
    }
    
    // MARK: Actions
    
    @IBAction func swapNowTapped(_ sender: UIButton) {
        delegate?.headerView(self, actionTapped: .swapNow)
    }
    
    @IBAction func learnMoreTapped(_ sender: UIButton) {
        delegate?.headerView(self, actionTapped: .learnMore)
    }
    
    @IBAction func contactSupportTapped(_ sender: UIButton) {
        delegate?.headerView(self, actionTapped: .contactSupport)
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        delegate?.dismissButtonTapped(self)
    }
    
    // MARK: Public Class Functions
    
    class func estimatedHeight(for width: CGFloat, model: KYCTiersHeaderViewModel) -> CGFloat {
        let interitemCTAVerticalPadding = model.actions?.count == 0 ? 0.0 : CTAInteritemPadding
        let totalCTAHeight: CGFloat = CGFloat((model.actions?.count ?? Int(0.0))) * CTAHeight
        var availableAmountHeight: CGFloat = 0.0
        var interitemLabelPadding: CGFloat = labelsInteritemPadding
        
        let adjustedWidth = width - horizontalPadding
        if let value = model.availableAmount {
            availableAmountHeight = NSAttributedString(
                string: value,
                attributes: [.font: availableAmountFont()]).heightForWidth(width: adjustedWidth)
            interitemLabelPadding += interitemLabelPadding
        }
        
        let headlineHeight = NSAttributedString(
            string: model.headline,
            attributes: [.font: headlineFont()]).heightForWidth(width: adjustedWidth)
        let descriptionHeight = NSAttributedString(
            string: model.description,
            attributes: [.font: limitDescriptionFont()]).heightForWidth(width: adjustedWidth)
        
        return interitemCTAVerticalPadding +
            totalCTAHeight +
            availableAmountHeight +
            interitemLabelPadding +
            headlineHeight +
            descriptionHeight +
            CTABottomPadding +
            labelsToCTAPadding +
            dismissButtonHeight +
            dismissButtonVerticalPadding
    }
    
    fileprivate class func availableAmountFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(48.0))
        return font.result
    }
    
    fileprivate class func headlineFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(17.0))
        return font.result
    }
    
    fileprivate class func limitDescriptionFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(15.0))
        return font.result
    }
}
