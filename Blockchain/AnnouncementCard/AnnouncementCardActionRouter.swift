//
//  AnnouncementCardActionRouter.swift
//  Blockchain
//
//  Created by kevinwu on 3/4/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// Class used to keep objects in memory while performing async operations for
// the CardsViewController instance.
@objc class AnnouncementCardActionRouter: NSObject {
    private let stellarAirdropRouter = StellarAirdropRouter()

    @objc func stellarAirdropCardActionTapped() {
        let appSettings = BlockchainSettings.App.shared
        stellarAirdropRouter.registerForCampaign(success: { user in
            appSettings.didRegisterForAirdropCampaignSucceed = true
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                Logger.shared.warning("Cannot start KYC. rootViewController is nil.")
                return
            }
            KYCCoordinator.shared.start(from: rootViewController, tier: .tier2)
        }, error: { error in
            appSettings.didRegisterForAirdropCampaignSucceed = false
            AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
        })
    }

    @objc func claimStellarInAdvanceCardActionTapped() {
        let appSettings = BlockchainSettings.App.shared
        stellarAirdropRouter.registerForCampaign(success: { user in
            appSettings.didRegisterForAirdropCampaignSucceed = true

        }, error: { error in
            appSettings.didRegisterForAirdropCampaignSucceed = false
            AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
        })
    }
}
