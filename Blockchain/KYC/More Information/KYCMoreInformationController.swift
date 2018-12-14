//
//  KYCMoreInformationController.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCMoreInformationController: KYCBaseViewController {

    @IBOutlet private var labelHeader: UILabel!
    @IBOutlet private var labelSubHeader: UILabel!
    @IBOutlet private var buttonNotNow: UIButton!
    @IBOutlet private var primaryButtonNext: PrimaryButtonContainer!

    // MARK: Factory

    override class func make(with coordinator: KYCCoordinator) -> KYCMoreInformationController {
        let controller = makeFromStoryboard()
        controller.coordinator = coordinator
        controller.pageType = .tier1ForcedTier2
        return controller
    }

    // MARK: View Controller Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        labelHeader.text = LocalizationConstants.KYC.moreInfoNeededHeaderText
        labelSubHeader.text = LocalizationConstants.KYC.moreInfoNeededSubHeaderText
        buttonNotNow.setTitle(LocalizationConstants.KYC.notNow, for: .normal)
        primaryButtonNext.actionBlock = { [unowned self] in
            self.coordinator.handle(event: .nextPageFromPageType(self.pageType, nil))
        }
    }

    // MARK: IBActions

    @IBAction func onNotNowTapped(_ sender: UIButton) {
        coordinator.finish()
    }
}
