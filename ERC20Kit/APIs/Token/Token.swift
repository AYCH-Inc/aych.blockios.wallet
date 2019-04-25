//
//  Token.swift
//  ERC20Kit
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit
import EthereumKit

public protocol ERC20Token {
    static var assetType: CryptoCurrency { get }
    static var name: String { get }
    static var contractAddress: String { get }

    static func cryptoValue(from majorValue: String) -> CryptoValue?
    static func cryptoValue(from majorValue: Decimal) -> CryptoValue
}

extension ERC20Token {
    public static var name: String {
        return assetType.rawValue
    }
    
    public static func cryptoValueFrom(minor minorUnits: String) -> CryptoValue? {
        guard let minorBigInt = BigInt(minorUnits) else {
            return nil
        }
        return Self.cryptoValueFrom(minorValue: minorBigInt)
    }
    
    public static func cryptoValue(from majorValue: String) -> CryptoValue? {
        guard let decimalValue = Decimal(string: majorValue) else {
            return nil
        }
        return Self.cryptoValue(from: decimalValue)
    }
    
    public static func cryptoValue(from majorValue: Decimal) -> CryptoValue {
        return CryptoValue.createFromMajorValue(majorValue, assetType: assetType)
    }
    
    public static func cryptoValueFrom(minorValue: BigInt) -> CryptoValue {
        return CryptoValue.createFromMinorValue(minorValue, assetType: assetType)
    }
}

public struct ERC20AccountResponse<Token: ERC20Token>: Decodable {
    let accountHash: String
    let tokenHash: String
    let balance: String
    let decimals: Int
    
    public init(
        accountHash: String,
        tokenHash: String,
        balance: String,
        decimals: Int) {
        self.accountHash = accountHash
        self.tokenHash = tokenHash
        self.balance = balance
        self.decimals = decimals
    }
}
