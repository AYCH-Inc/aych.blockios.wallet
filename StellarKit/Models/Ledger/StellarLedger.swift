//
//  StellarLedger.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

// The `baseFeeInStroops` the network charges per operation in a transaction.
// This field is in stroops, which are 1/10,000,000th of a lumen.
// The `baseReserveInStroops` is what the network uses when
// calculating an account’s minimum balance.
public struct StellarLedger {
    public let identifier: String
    public let token: String
    public let sequence: Int
    public let transactionCount: Int?
    public let operationCount: Int
    public let closedAt: Date
    public let totalCoins: String
    public let baseFeeInStroops: Int?
    public let baseReserveInStroops: Int?
    
    public init(identifier: String, token: String, sequence: Int, transactionCount: Int?, operationCount: Int, closedAt: Date, totalCoins: String, baseFeeInStroops: Int?, baseReserveInStroops: Int?) {
        self.identifier = identifier
        self.token = token
        self.sequence = sequence
        self.transactionCount = transactionCount
        self.operationCount = operationCount
        self.closedAt = closedAt
        self.totalCoins = totalCoins
        self.baseFeeInStroops = baseFeeInStroops
        self.baseReserveInStroops = baseReserveInStroops
    }
}

extension StellarLedger: Equatable {
    public static func == (lhs: StellarLedger, rhs: StellarLedger) -> Bool {
        return lhs.baseFeeInStroops == rhs.baseFeeInStroops &&
        lhs.baseReserveInStroops == rhs.baseReserveInStroops
    }
}

public extension StellarLedger {
    var baseFeeInXlm: CryptoValue? {
        guard let baseFeeInStroops = baseFeeInStroops else { return nil }
        return CryptoValue.lumensFromStroops(int: baseFeeInStroops)
    }
    
    var baseReserveInXlm: CryptoValue? {
        guard let baseReserveInStroops = baseReserveInStroops else { return nil }
        return CryptoValue.lumensFromStroops(int: baseReserveInStroops)
    }
}

public extension StellarLedger {
    func apply(baseFeeInStroops: Int) -> StellarLedger {
        return StellarLedger(
            identifier: identifier,
            token: token,
            sequence: sequence,
            transactionCount: transactionCount,
            operationCount: operationCount,
            closedAt: closedAt,
            totalCoins: totalCoins,
            baseFeeInStroops: baseFeeInStroops,
            baseReserveInStroops: baseReserveInStroops
        )
    }
}
