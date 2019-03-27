//
//  BitcoinTransactionFee.swift
//  BitcoinKit
//
//  Created by AlexM on 3/1/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct BitcoinTransactionFee: TransactionFee, Decodable {
    public static var cryptoType: HasPathComponent = CryptoCurrency.bitcoin
    public static let `default` = BitcoinTransactionFee(
        limits: BitcoinTransactionFee.defaultLimits,
        regular: 5,
        priority: 11
    )
    public static let defaultLimits = TransactionFeeLimits(min: 2, max: 16)
    
    public var limits: TransactionFeeLimits
    public var regular: CryptoValue
    public var priority: CryptoValue
    
    enum CodingKeys: String, CodingKey {
        case regular
        case priority
        case limits
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let regularFee = try values.decode(Int.self, forKey: .regular)
        let priorityFee = try values.decode(Int.self, forKey: .priority)
        regular = CryptoValue.bitcoinFromSatoshis(int: regularFee)
        priority = CryptoValue.bitcoinFromSatoshis(int: priorityFee)
        limits = try values.decode(TransactionFeeLimits.self, forKey: .limits)
    }
    
    init(limits: TransactionFeeLimits, regular: Int, priority: Int) {
        self.limits = limits
        self.regular = CryptoValue.bitcoinFromSatoshis(int: regular)
        self.priority = CryptoValue.bitcoinFromSatoshis(int: priority)
    }
}
