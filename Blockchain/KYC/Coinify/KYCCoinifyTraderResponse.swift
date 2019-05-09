//
//  KYCCoinifyTraderResponse.swift
//  Blockchain
//
//  Created by AlexM on 4/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCCoinifyTraderResponse: Decodable {
    let trader: KYCCoinifyTrader
}

extension KYCCoinifyTraderResponse {
    var traderIdentifier: Int {
        return trader.id
    }
}

struct KYCCoinifyTrader: Decodable {
    let id: Int
}
