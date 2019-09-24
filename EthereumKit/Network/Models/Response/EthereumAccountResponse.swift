//
//  EthereumAccountResponse.swift
//  EthereumKit
//
//  Created by Jack on 19/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt

public struct EthereumAccountResponse: Codable {
    
    public let txns: [EthereumHistoricalTransactionResponse]
}

public struct EthereumHistoricalTransactionResponse: Codable {
    
    public let blockNumber: Int
    
    public let timeStamp: Int
    
    public let hash: String
    
    public let blockHash: String
    
    public let from: String
    
    public let to: String
    
    public let value: String
    
    public let gas: Int
    
    public let gasPrice: Int
    
    public let gasUsed: Int
}

