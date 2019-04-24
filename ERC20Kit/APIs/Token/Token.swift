//
//  Token.swift
//  ERC20Kit
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

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
    
    public static func cryptoValue(from majorValue: String) -> CryptoValue? {
        guard let decimalValue = Decimal(string: majorValue) else {
            return nil
        }
        return Self.cryptoValue(from: decimalValue)
    }
    
    public static func cryptoValue(from majorValue: Decimal) -> CryptoValue {
        return CryptoValue.createFromMajorValue(majorValue, assetType: assetType)
    }
}

public struct ERC20TransferResponse<Token: ERC20Token>: Decodable {
    let logIndex: String
    let tokenHash: String
    let accountFrom: String
    let accountTo: String
    let value: String
    let decimals: Int
    let blockHash: String
    let transactionHash: String
    let blockNumber: String
    let idxFrom: String
    let idxTo: String
    let accountIdxFrom: String
    let accountIdxTo: String
}

public struct ERC20AccountResponse<Token: ERC20Token>: Decodable {
    let accountHash: String
    let tokenHash: String
    let balance: String
    let totalSent: String
    let totalReceived: String
    let decimals: Int
    let transferCount: String
    let transfers: [ERC20TransferResponse<Token>]
    let page: String
    let size: Int
    
    init(
        accountHash: String,
        tokenHash: String,
        balance: String,
        totalSent: String,
        totalReceived: String,
        decimals: Int,
        transferCount: String,
        transfers: [ERC20TransferResponse<Token>],
        page: String,
        size: Int) {
        self.accountHash = accountHash
        self.tokenHash = tokenHash
        self.balance = balance
        self.totalSent = totalSent
        self.totalReceived = totalReceived
        self.decimals = decimals
        self.transferCount = transferCount
        self.transfers = transfers
        self.page = page
        self.size = size
    }
}
