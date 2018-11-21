//
//  ExchangeTradingPairs.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct ExchangeTradingPairs: Decodable {
    // TICKET: IOS-1663
    // This cannot be [TradingPair] until TradingPair supports all fiat currencies
    // This would require AssetType to support all fiat currencies as well.
    let pairs: [String]
    
    enum CodingKeys: String, CodingKey {
        case pairs
    }
}
