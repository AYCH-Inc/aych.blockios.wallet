//
//  EthereumTransactionCandidate.swift
//  EthereumKit
//
//  Created by Jack on 26/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import web3swift
import BigInt

public struct EthereumTransactionCandidate: Equatable, Hashable {
    public typealias Address = EthereumAssetAddress
    
    public var identifier: String {
        return "\(hashValue)"
    }
    
    public let fromAddress: Address
    
    public let toAddress: Address
    
    public let amount: BigUInt
    
    public let createdAt: Date
    
    public let gasPrice: BigUInt?
    
    public let gasLimit: BigUInt?
    
    public let memo: String?
    
    public init?(
        fromAddress: Address,
        toAddress: Address,
        amount: String,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil,
        createdAt: Date = Date(),
        memo: String? = nil) {
        
        guard let amountBigInt = BigUInt(amount, decimals: CryptoCurrency.ethereum.maxDecimalPlaces) else {
            return nil
        }
        
        self.init(
            fromAddress: fromAddress,
            toAddress: toAddress,
            amount: amountBigInt,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            createdAt: createdAt,
            memo: memo
        )
    }
    
    public init(
        fromAddress: Address,
        toAddress: Address,
        amount: BigUInt,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil,
        createdAt: Date = Date(),
        memo: String? = nil) {
        
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.amount = amount
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.createdAt = createdAt
        self.memo = memo
        
        print("\n\n\n")
        print("\n     fromAddress: \(self.fromAddress)")
        print("\n       toAddress: \(self.toAddress)")
        print("\n          amount: \(self.amount)")
        print("\n       createdAt: \(self.createdAt)")
        print("\n        gasPrice: \(self.gasPrice)")
        print("\n        gasLimit: \(self.gasLimit)")
        print("\n            memo: \(self.memo)")
        print("\n\n\n")
    }
}


