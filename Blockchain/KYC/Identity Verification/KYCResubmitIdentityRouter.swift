//
//  KYCResubmitIdentityRouter.swift
//  Blockchain
//
//  Created by kevinwu on 1/24/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Router for handling the KYC document resubmission flow
class KYCResubmitIdentityRouter: DeepLinkRouting {

    private let appSettings: BlockchainSettings.App
    private let kycCoordinator: KYCCoordinator

    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        kycCoordinator: KYCCoordinator = KYCCoordinator.shared
    ) {
        self.appSettings = appSettings
        self.kycCoordinator = kycCoordinator
    }

    func routeIfNeeded() -> Bool {
        // Only route if the user actually tapped on the resubmission link
        guard appSettings.didTapOnDocumentResubmissionDeepLink else {
            return false
        }

        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
            return false
        }
        kycCoordinator.start(from: viewController, tier: .tier2)
        return true
    }
}
