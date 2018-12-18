//
//  KYCUnavailableHeaderView.swift
//  Blockchain
//
//  Created by AlexM on 12/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

/// This header view is supposed to be used when you want to either show
/// CTAs like `Learn More` or `Contact Support`, or you want to show the
/// "standard" header that only has a `title` and `subtitle` and no information
/// regarding their available funds for their current tier. In fact you shouldn't
/// use or see this header if the user is actively enrolled in either of the tiers. 
class KYCCTAHeaderView: KYCTiersHeaderView {
    
    static let identifier: String = String(describing: KYCCTAHeaderView.self)
    
    // MARK: Private Static Properties
    
    fileprivate static let horizontalPadding: CGFloat = 32.0
    fileprivate static let CTAHeight: CGFloat = 56.0
    fileprivate static let CTAInteritemPadding: CGFloat = 16.0
    fileprivate static let CTABottomPadding: CGFloat = 8.0
    fileprivate static let labelsToCTAPadding: CGFloat = 32.0
    fileprivate static let topToLabelsPadding: CGFloat = 32.0
    fileprivate static let labelsInteritemPadding: CGFloat = 4.0
    fileprivate static let dismissButtonHeight: CGFloat = 30.0
    fileprivate static let dismissButtonVerticalPadding: CGFloat = 36.0
    fileprivate static let labelsToBottomPadding: CGFloat = 4.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var title: UILabel!
    @IBOutlet fileprivate var subtitle: UILabel!
    @IBOutlet fileprivate var learnMoreButton: UIButton!
    @IBOutlet fileprivate var contactSupportButton: UIButton!
    @IBOutlet fileprivate var dismissButton: UIButton!
    @IBOutlet fileprivate var labelStackViewToBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var labelStackViewToCTAsConstraint: NSLayoutConstraint!
    
    @IBOutlet var stackViewToTopConstraint: NSLayoutConstraint!
    @IBOutlet var stackViewToDismissalButtonConstraint: NSLayoutConstraint!
    
    fileprivate var CTAs: [UIButton] {
        return [learnMoreButton, contactSupportButton]
    }
    
    // MARK: Public Class Functions
    
    override func configure(with viewModel: KYCTiersHeaderViewModel) {
        title.text = viewModel.title
        subtitle.text = viewModel.subtitle
        if let actions = viewModel.actions {
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
        
        learnMoreButton.setTitle(LocalizationConstants.ObjCStrings.BC_STRING_LEARN_MORE, for: .normal)
        contactSupportButton.setTitle(LocalizationConstants.KYC.contactSupport, for: .normal)
        dismissButton.isHidden = viewModel.suppressDismissCTA
        if viewModel.suppressDismissCTA, stackViewToDismissalButtonConstraint.isActive {
            NSLayoutConstraint.deactivate([stackViewToDismissalButtonConstraint])
            NSLayoutConstraint.activate([stackViewToTopConstraint])
        }
        guard viewModel.actions == nil else { return }
        guard labelStackViewToBottomConstraint.isActive == false else { return }
        NSLayoutConstraint.deactivate([labelStackViewToCTAsConstraint])
        NSLayoutConstraint.activate([labelStackViewToBottomConstraint])
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override class func estimatedHeight(for width: CGFloat, model: KYCTiersHeaderViewModel) -> CGFloat {
        let interitemCTAVerticalPadding = model.actions == nil ? 0.0 : CTAInteritemPadding
        let totalCTAHeight: CGFloat = CGFloat((model.actions?.count ?? Int(0.0))) * CTAHeight
        
        var titleHeight: CGFloat = 0.0
        var subtitleHeight: CGFloat = 0.0
        let adjustedWidth = width - horizontalPadding
        
        if let title = model.title {
            titleHeight = NSAttributedString(
                string: title,
                attributes: [.font: titleFont()]).heightForWidth(width: adjustedWidth)
        }
        
        if let subtitle = model.subtitle {
            subtitleHeight = NSAttributedString(
                string: subtitle,
                attributes: [.font: subtitleFont()]).heightForWidth(width: adjustedWidth)
        }
        
        let titleHeights = titleHeight + subtitleHeight
        var padding = labelsInteritemPadding + dismissButtonVerticalPadding
        if model.actions == nil {
            padding += labelsToBottomPadding
        } else {
            padding += (CTABottomPadding + labelsToCTAPadding)
        }
        let result = interitemCTAVerticalPadding +
            totalCTAHeight +
            titleHeights +
            dismissButtonHeight +
            padding
        
        return result
    }
    
    // MARK: Actions
    
    @IBAction func learnMoreTapped(_ sender: UIButton) {
        delegate?.headerView(self, actionTapped: .learnMore)
    }
    
    @IBAction func contactSupportTapped(_ sender: UIButton) {
        delegate?.headerView(self, actionTapped: .contactSupport)
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        delegate?.dismissButtonTapped(self)
    }
    
    // MARK: Fonts
    
    fileprivate class func titleFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(20.0))
        return font.result
    }
    
    fileprivate class func subtitleFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(17.0))
        return font.result
    }
}
