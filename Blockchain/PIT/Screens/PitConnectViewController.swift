//
//  PitConnectViewController.swift
//  Blockchain
//
//  Created by AlexM on 7/1/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

class PitConnectViewController: UIViewController {
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var shadowView: UIView!
    @IBOutlet private var outerContainerView: UIView!
    @IBOutlet private var outerStackView: UIStackView!
    @IBOutlet private var learnMoreButton: UIButton!
    @IBOutlet private var connectNowButton: UIButton!
    
    // MARK: Private IBOutlets (UILabel)
    
    @IBOutlet private var pitDescriptionLabel: UILabel!
    @IBOutlet private var lightningTradesLabel: UILabel!
    @IBOutlet private var reliabilityLabel: UILabel!
    @IBOutlet private var lowFaresLabel: UILabel!
    @IBOutlet private var builtByBlockchainLabel: UILabel!
    @IBOutlet private var ableToLabel: UILabel!
    @IBOutlet private var notAbleToLabel: UILabel!
    
    @IBOutlet private var shareYourStatus: UILabel!
    @IBOutlet private var exchangeAddresses: UILabel!
    @IBOutlet private var viewWalletPassword: UILabel!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outerContainerView.layer.cornerRadius = 8.0
        outerContainerView.clipsToBounds = true
        
        shadowView.layer.shadowColor = #colorLiteral(red: 0.87, green: 0.87, blue: 0.87, alpha: 1).cgColor
        shadowView.layer.shadowRadius = 4.0
        shadowView.layer.shadowOffset = .init(width: 0, height: 2.0)
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.cornerRadius = 8.0
        
        learnMoreButton.layer.borderColor = #colorLiteral(red: 0.3, green: 0.09, blue: 0.73, alpha: 1).cgColor
        learnMoreButton.layer.borderWidth = 1.0
        learnMoreButton.layer.cornerRadius = 4.0
        
        connectNowButton.layer.cornerRadius = 4.0
        
        applyCopy()
    }
    
    private func applyCopy() {
        pitDescriptionLabel.text = LocalizationConstants.PIT.ConnectionPage.Descriptors.description
        lightningTradesLabel.text = LocalizationConstants.PIT.ConnectionPage.Descriptors.lightningFast
        lowFaresLabel.text = LocalizationConstants.PIT.ConnectionPage.Descriptors.lowFees
        builtByBlockchainLabel.text = LocalizationConstants.PIT.ConnectionPage.Descriptors.builtByBlockchain
        reliabilityLabel.text = LocalizationConstants.PIT.ConnectionPage.Descriptors.reliable
        
        ableToLabel.text = LocalizationConstants.PIT.ConnectionPage.Features.pitWillBeAbleTo
        notAbleToLabel.text = LocalizationConstants.PIT.ConnectionPage.Features.pitWillNotBeAbleTo
        
        shareYourStatus.attributedText = NSAttributedString(
            string: LocalizationConstants.PIT.ConnectionPage.Features.shareStatus,
            attributes: [.font: copyFont()
            ]
        ).asBulletPoint()
        exchangeAddresses.attributedText = NSAttributedString(
            string: LocalizationConstants.PIT.ConnectionPage.Features.exchangeAddresses,
            attributes: [.font: copyFont()
            ]
        ).asBulletPoint()
        viewWalletPassword.attributedText = NSAttributedString(
            string: LocalizationConstants.PIT.ConnectionPage.Features.viewYourPassword,
            attributes: [.font: copyFont()
            ]
        ).asBulletPoint()
        
        learnMoreButton.setTitle(LocalizationConstants.PIT.ConnectionPage.Actions.learnMore, for: .normal)
        connectNowButton.setTitle(LocalizationConstants.PIT.ConnectionPage.Actions.connectNow, for: .normal)
    }
    
    private func copyFont() -> UIFont {
        return Font(.branded(.montserratMedium), size: .custom(14.0)).result
    }
    
    // MARK: Actions
    
    @IBAction private func learnMoreTapped(_ sender: UIButton) {
        // TODO:
    }
    
    @IBAction private func connectNowTapped(_ sender: UIButton) {
        // TODO:
    }
}
