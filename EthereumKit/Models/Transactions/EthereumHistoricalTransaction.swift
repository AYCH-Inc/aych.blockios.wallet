//
//  EthereumTransaction.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import BigInt

public protocol EthereumTransaction {
    var isConfirmed: Bool { get }
    var confirmations: UInt { get }
}

public struct EthereumHistoricalTransaction: EthereumTransaction, HistoricalTransaction, Mineable {
    
    public typealias Address = EthereumAssetAddress
    
    public var fromAddress: EthereumAssetAddress
    public var toAddress: EthereumAssetAddress
    public var identifier: String
    public var direction: Direction
    public var amount: String
    public var transactionHash: String
    public var createdAt: Date
    public var fee: CryptoValue?
    public var memo: String?
    public var confirmations: UInt
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
        fee: CryptoValue?,
        memo: String?,
        confirmations: UInt) {
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
    }
    
    public init(response: EthereumHistoricalTransactionResponse,
                memo: String? = nil,
                accountAddress: String,
                latestBlock: Int) {
        self.identifier = response.hash
        self.fromAddress = EthereumAssetAddress(publicKey: response.from)
        self.toAddress = EthereumAssetAddress(publicKey: response.to)
        self.direction = EthereumHistoricalTransaction.direction(
            to: response.to,
            from: response.from,
            accountAddress: accountAddress
        )
        self.amount = EthereumHistoricalTransaction.amount(value: response.value)
        self.transactionHash = response.hash
        self.createdAt = EthereumHistoricalTransaction.created(
            timestamp: response.timeStamp
        )
        self.fee = EthereumHistoricalTransaction.fee(
            gasPrice: response.gasPrice,
            gasUsed: response.gasUsed
        )
        self.memo = memo
        self.confirmations = EthereumHistoricalTransaction.confirmations(
            latestBlock: latestBlock,
            blockNumber: response.blockNumber
        )
    }
    
    private static func created(timestamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    private static func amount(value: String) -> String {
        guard
            let crypto = CryptoValue.etherFromWei(string: value),
            let ethereum = try? EthereumValue(crypto: crypto)
        else {
            return "0"
        }
        return ethereum.toDisplayString(includeSymbol: false, locale: Locale.current)
    }
    
    private static func direction(to: String, from: String, accountAddress: String) -> Direction {
        let incoming = to.lowercased() == accountAddress.lowercased()
        let outgoing = from.lowercased() == accountAddress.lowercased()
        if incoming && outgoing {
            return .transfer
        }
        if incoming {
            return .credit
        }
        return .debit
    }
    
    private static func fee(gasPrice: Int, gasUsed: Int) -> CryptoValue {
        let fee = gasPrice * gasUsed
        return CryptoValue.etherFromWei(string: "\(fee)") ?? CryptoValue.etherZero
    }
    
    private static func confirmations(latestBlock: Int, blockNumber: Int) -> UInt {
        let confirmations = latestBlock - blockNumber + 1
        guard confirmations > 0 else {
            return 0
        }
        return UInt(confirmations)
    }
}
