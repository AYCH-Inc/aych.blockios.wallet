//
//  KYCOnboardingViewController.swift
//  Blockchain
//
//  Created by AlexM on 2/22/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// NOTE: This is likely temporary. Swap has been moved to the tab bar.
/// Because of this we need a screen that serves as a placeholder and CTA
/// for user's who have not KYC'd. 
class KYCOnboardingViewController: UIViewController {
    
    var action: (() -> Void)?
    
    @IBOutlet fileprivate var welcomeDescription: UILabel!
    @IBOutlet fileprivate var beginNowButton: PrimaryButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.KYC.welcome
        welcomeDescription.text = LocalizationConstants.KYC.welcomeMainText
    }
    
    @IBAction func beginNowTapped(_ sender: UIButton) {
        action?()
    }
}
