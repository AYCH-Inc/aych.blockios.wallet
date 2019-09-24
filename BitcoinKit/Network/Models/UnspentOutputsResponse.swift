//
//  UnspentOutputsResponse.swift
//  BitcoinKit
//
//  Created by Jack on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct UnspentOutputsResponse: Codable {
    
    let unspent_outputs: [UnspentOutputResponse]
}

struct UnspentOutputResponse: Codable {
    
    struct XPub: Codable {
        let m: String
        let path: String
    }
    
    let tx_hash: String
    let script: String
    let value: Decimal
    let confirmations: UInt
    let xpub: XPub
    let tx_index: Int
    let replayable: Bool?
}
