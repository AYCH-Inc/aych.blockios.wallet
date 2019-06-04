//
//  EthereumTransaction.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct EthereumHistoricalTransaction: HistoricalTransaction, Mineable {

    public typealias Address = EthereumAssetAddress

    public let identifier: String

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
    
    public init(
                identifier: String,
                fromAddress: Address,
                toAddress: Address,
                direction: Direction,
                amount: String,
                transactionHash: String,
                createdAt: Date,
                fee: Int?,
                memo: String?,
                confirmations: Int) {
        self.identifier = identifier
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.direction = direction
        self.amount = amount
        self.transactionHash = transactionHash
        self.createdAt = createdAt
        self.fee = fee
        self.memo = memo
        self.confirmations = confirmations
        
        print("\n\n\n")
        print("\n      identifier: \(self.identifier)")
        print("\n     fromAddress: \(self.fromAddress)")
        print("\n       toAddress: \(self.toAddress)")
        print("\n       direction: \(self.direction)")
        print("\n          amount: \(self.amount)")
        print("\n transactionHash: \(self.transactionHash)")
        print("\n       createdAt: \(self.createdAt)")
        print("\n             fee: \(self.fee)")
        print("\n            memo: \(self.memo)")
        print("\n   confirmations: \(self.confirmations)")
        print("\n\n\n")
    }
}
