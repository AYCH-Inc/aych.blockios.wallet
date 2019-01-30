//
//  KYCOnboardingNavigationController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

protocol KYCOnboardingNavigationControllerDelegate: class {
    func navControllerCTAType() -> NavigationCTA
    func navControllerRightBarButtonTapped(_ navController: KYCOnboardingNavigationController)
}

/// NOTE: - This class prefetches some of the data to mitigate loading states in subsequent view controllers
final class KYCOnboardingNavigationController: UINavigationController {
    
    weak var onboardingDelegate: KYCOnboardingNavigationControllerDelegate?

    // MARK: - Initialization
    
    class func make() -> KYCOnboardingNavigationController {
        let controller = makeFromStoryboard()
        return controller
    }
    
    func setupBarButtonItem() {
        guard let CTA = onboardingDelegate?.navControllerCTAType() else { return }
        let button = UIBarButtonItem(
            image: CTA.image,
            style: .plain,
            target: self,
            action: #selector(rightBarButtonTapped)
        )
        guard let navItem = visibleViewController?.navigationItem else { return }
        navItem.rightBarButtonItem = CTA.visibility.isHidden ? nil : button
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc fileprivate func rightBarButtonTapped() {
        onboardingDelegate?.navControllerRightBarButtonTapped(self)
    }
}
