//
//  StellarTransactionFee.swift
//  StellarKit
//
//  Created by Jack on 26/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct StellarTransactionFee: TransactionFee, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case regular
        case priority
        case limits
    }
    
    public static var cryptoType: HasPathComponent = CryptoCurrency.stellar
    public static let `default` = StellarTransactionFee(
        limits: StellarTransactionFee.defaultLimits,
        regular: 100,
        priority: 10000
    )
    public static let defaultLimits = TransactionFeeLimits(min: 100, max: 10000)
    
    public var limits: TransactionFeeLimits
    public var regular: CryptoValue
    public var priority: CryptoValue
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let regularFee = try values.decode(Int.self, forKey: .regular)
        let priorityFee = try values.decode(Int.self, forKey: .priority)

        guard let regularValue = CryptoValue.lumensFromStroops(string: String(regularFee)) else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.regular],
                debugDescription: "Expected CryptoValue pair from \(regularFee)"
            )
            throw DecodingError.valueNotFound(Int.self, context)
        }
        guard let priorityValue = CryptoValue.lumensFromStroops(string: String(priorityFee)) else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.priority],
                debugDescription: "Expected CryptoValue pair from \(priorityFee)"
            )
            throw DecodingError.valueNotFound(Int.self, context)
        }

        regular = regularValue
        priority = priorityValue
        limits = try values.decode(TransactionFeeLimits.self, forKey: .limits)
    }

    public init(limits: TransactionFeeLimits, regular: Int, priority: Int) {
        self.limits = limits
        self.regular = CryptoValue.lumensFromStroops(string: String(regular))!
        self.priority = CryptoValue.lumensFromStroops(string: String(priority))!
    }
}
