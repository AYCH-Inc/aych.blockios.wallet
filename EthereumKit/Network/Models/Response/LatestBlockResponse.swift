//
//  LatestBlockResponse.swift
//  EthereumKit
//
//  Created by Jack on 19/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct LatestBlockResponse: Codable {
    
    /// The latest block number
    public let number: Int
}
