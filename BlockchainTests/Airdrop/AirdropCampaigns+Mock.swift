//
//  AirdropCampaigns+Mock.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 02/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@testable import Blockchain

extension AirdropCampaigns {
    static var mock: AirdropCampaigns {
        let blockstack = AirdropCampaigns.Campaign(
            name: "BLOCKSTACK",
            state: .started,
            userState: .none,
            attributes: .empty,
            transactions: [
                .init(
                    state: .pendingDeposit,
                    fiatValue: 1000,
                    fiatCurrency: "USD",
                    withdrawalQuantity: 2083333325,
                    withdrawalCurrency: "STX",
                    withdrawalAt: "2018-12-27T14:54:16.347Z"
                )
            ],
            updateDate: Date().addingTimeInterval(-259200),
            endDate: Date().addingTimeInterval(-259200)
        )
        let pax = AirdropCampaigns.Campaign(
            name: "POWER_PAX",
            state: .started,
            userState: .registered,
            attributes: .empty,
            transactions: [
                .init(
                    state: .pendingWithdrawal,
                    fiatValue: 5000,
                    fiatCurrency: "GBP",
                    withdrawalQuantity: 6599,
                    withdrawalCurrency: "PAX",
                    withdrawalAt: "2020-01-15T14:54:16.347Z"
                )
            ],
            updateDate: Date().addingTimeInterval(-100000),
            endDate: Date().addingTimeInterval(-259200)
        )
        let sunriver = AirdropCampaigns.Campaign(
            name: "SUNRIVER",
            state: .ended,
            userState: .rewardReceived,
            attributes: .empty,
            transactions: [
                .init(
                    state: .finishedWithdrawal,
                    fiatValue: 2500,
                    fiatCurrency: "USD",
                    withdrawalQuantity: 2083333325,
                    withdrawalCurrency: "XLM",
                    withdrawalAt: "2018-12-27T14:54:16.347Z"
                )
            ],
            updateDate: Date().addingTimeInterval(-759200),
            endDate: Date().addingTimeInterval(-259200)
        )
        return .init(campaigns: Set([blockstack, sunriver, pax]))
    }
}
