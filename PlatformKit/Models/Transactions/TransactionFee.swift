//
//  TransactionFee.swift
//  PlatformKit
//
//  Created by AlexM on 3/1/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt

public struct TransactionFeeLimits: Decodable {
    public let min: Int
    public let max: Int
    
    public init(min: Int, max: Int) {
        self.min = min
        self.max = max
    }
}

public extension TransactionFeeLimits {
    public static let bitcoinDefault = TransactionFeeLimits(min: 2, max: 16)
    public static let ethereumDefault = TransactionFeeLimits(min: 23, max: 23)
}

public protocol TransactionFee {
    var limits: TransactionFeeLimits { get }
    var regular: CryptoValue { get }
    var priority: CryptoValue { get }
}

public struct EthereumTransactionFee: TransactionFee, Decodable {
    public var limits: TransactionFeeLimits
    public var regular: CryptoValue
    public var priority: CryptoValue
    public var gasLimit: Int
    
    enum CodingKeys: String, CodingKey {
        case regular
        case priority
        case limits
        case gasLimit
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let regularFee = try values.decode(Int.self, forKey: .regular)
        let priorityFee = try values.decode(Int.self, forKey: .priority)
        guard let regularValue = CryptoValue.etherFromGwei(string: String(regularFee)) else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.regular],
                debugDescription: "Expected CryptoValue pair from \(regularFee)"
            )
            throw DecodingError.valueNotFound(Int.self, context)
        }
        guard let priorityValue = CryptoValue.etherFromGwei(string: String(priorityFee)) else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.priority],
                debugDescription: "Expected CryptoValue pair from \(priorityFee)"
            )
            throw DecodingError.valueNotFound(Int.self, context)
        }
        
        regular = regularValue
        priority = priorityValue
        limits = try values.decode(TransactionFeeLimits.self, forKey: .limits)
        gasLimit = try values.decode(Int.self, forKey: .gasLimit)
    }
    
    init(limits: TransactionFeeLimits, regular: Int, priority: Int, gasLimit: Int) {
        self.limits = limits
        self.regular = CryptoValue.etherFromGwei(string: String(regular))!
        self.priority = CryptoValue.etherFromGwei(string: String(priority))!
        self.gasLimit = gasLimit
    }
}

public extension EthereumTransactionFee {
    public static let `default` = EthereumTransactionFee(
        limits: .ethereumDefault,
        regular: 5,
        priority: 11,
        gasLimit: 21000
    )
}

public extension EthereumTransactionFee {
    /// Fees must be provided in `gwei`.
    var priorityGweiValue: String {
        return priority.gwei
    }
    
    /// Fees must be provided in `gwei`.
    var regularGweiValue: String {
        return regular.gwei
    }
}

fileprivate extension CryptoValue {
    /// Fees must be provided in `gwei`.
    /// We don't want `CryptoValue` to handle conversions between anything other than
    /// minor to major values so, this extension is private. 
    var gwei: String {
        let gweiValue = amount / BigInt(integerLiteral: 1_000_000_000)
        return gweiValue.description
    }
}
