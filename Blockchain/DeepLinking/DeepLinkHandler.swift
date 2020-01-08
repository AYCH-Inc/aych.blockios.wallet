//
//  DeepLinkHandler.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Firebase
import ToolKit
import PlatformKit

class DeepLinkHandler {

    private let appSettings: BlockchainSettings.App

    init(appSettings: BlockchainSettings.App = BlockchainSettings.App.shared) {
        self.appSettings = appSettings
    }

    func handle(deepLink: String,
                supportedRoutes: [DeepLinkRoute] = DeepLinkRoute.allCases) {
        Logger.shared.debug("Attempting to handle deep link \(deepLink)")
        guard let route = DeepLinkRoute.route(from: deepLink, supportedRoutes: supportedRoutes),
            let payload = DeepLinkPayload.create(from: deepLink, supportedRoutes: supportedRoutes) else {
            return
        }

        switch route {
        case .xlmAirdop:
            handleXlmAirdrop(payload.params)
        case .kyc,
             .kycVerifyEmail:
            handleKyc()
        case .kycDocumentResubmission:
            handleKycDocumentResubmission(payload.params)
        case .exchangeVerifyEmail,
             .exchangeLinking:
            handleExchangeLinking(payload.params)
        }
    }

    private func handleXlmAirdrop(_ params: [String: String]) {
        appSettings.didTapOnAirdropDeepLink = true
        appSettings.didAttemptToRouteForAirdrop = false
        Analytics.setUserProperty(AnalyticsService.Campaigns.sunriver.rawValue, forName: "campaign")
    }

    private func handleKycDocumentResubmission(_ params: [String: String]) {
        appSettings.didTapOnDocumentResubmissionDeepLink = true
        appSettings.documentResubmissionLinkReason = params[DeepLinkConstant.documentResubmissionReason]
    }
    
    private func handleExchangeLinking(_ params: [String: String]) {
        appSettings.didTapOnExchangeDeepLink = true
        appSettings.exchangeLinkIdentifier = params[DeepLinkConstant.linkId]
    }

    private func handleKyc() {
        appSettings.didTapOnKycDeepLink = true
    }
}
