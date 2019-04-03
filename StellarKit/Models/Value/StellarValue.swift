//
//  StellarValue.swift
//  StellarKit
//
//  Created by Jack on 02/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public enum StellarValueError: Error {
    case integerOverflow
    case notAStellarValue
}

public struct StellarValue {
    public let value: CryptoValue
    
    public func stroops() throws -> Int {
        guard value.majorValue < Decimal(Int32.max / 10^7) else {
            throw StellarValueError.integerOverflow
        }
        let stroops: Int = NSDecimalNumber(decimal: value.majorValue)
            .multiplying(
                byPowerOf10: 7,
                withBehavior: NSDecimalNumberHandler(
                    roundingMode: .bankers,
                    scale: 2,
                    raiseOnExactness: true,
                    raiseOnOverflow: true,
                    raiseOnUnderflow: true,
                    raiseOnDivideByZero: true
                )
            )
            .intValue
        return stroops
    }
    
    public init(value: CryptoValue) throws {
        guard value.currencyType == .stellar else {
            throw StellarValueError.notAStellarValue
        }
        self.value = value
    }
}
