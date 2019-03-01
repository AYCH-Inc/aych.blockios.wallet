//
//  EthereumTransaction.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct EthereumTransaction: HistoricalTransaction, Mineable {

    public typealias Address = EthereumAssetAddress

    public let identifier: String

    public let token: String

    public let fromAddress: Address

    public let toAddress: Address

    public let direction: Direction

    public let amount: String

    public let transactionHash: String

    public let createdAt: Date

    public let fee: Int?

    public let memo: String?

    // MARK: - Mineable

    public let confirmations: Int

    public var isConfirmed: Bool {
        return confirmations == 12
    }
}