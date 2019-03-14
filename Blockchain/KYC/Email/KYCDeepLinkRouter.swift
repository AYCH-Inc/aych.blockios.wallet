//
//  KYCVerifyEmailRouter.swift
//  Blockchain
//
//  Created by kevinwu on 2/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Router for handling the KYC verify email flow
class KYCDeepLinkRouter: DeepLinkRouting {

    private let appSettings: BlockchainSettings.App
    private let kycSettings: KYCSettingsAPI
    private let kycCoordinator: KYCCoordinator

    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        kycSettings: KYCSettingsAPI = KYCSettings.shared,
        kycCoordinator: KYCCoordinator = KYCCoordinator.shared
    ) {
        self.appSettings = appSettings
        self.kycSettings = kycSettings
        self.kycCoordinator = kycCoordinator
    }

    func routeIfNeeded() {
        // Only route if the user actually tapped on the verify email link
        guard appSettings.didTapOnKycDeepLink else {
            return
        }
        appSettings.didTapOnKycDeepLink = false

        // Only route if the user was completing kyc
        guard kycSettings.isCompletingKyc else {
            return
        }

        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        kycCoordinator.start(from: viewController)
    }
}
