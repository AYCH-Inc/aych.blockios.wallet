//
//  BitcoinQRMetadata.swift
//  BitcoinKit
//
//  Created by Jack on 05/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct BitcoinQRMetadata: CryptoAssetQRMetadata {
    public var address: String
    
    public var amount: String?
    
    public var paymentRequestUrl: String?
    
    public var absoluteString: String {
        let payload = BitcoinURLPayload(
            address: address,
            amount: amount,
            includeScheme: includeScheme
        )
        return payload.absoluteString
    }
    
    public var includeScheme: Bool = false
    
    public static var scheme: String {
        return AssetConstants.URLSchemes.bitcoin
    }
    
    public init(address: String, includeScheme: Bool = false) {
        self.address = address
        self.includeScheme = includeScheme
    }
    
    public init(address: String, amount: String?, includeScheme: Bool = false) {
        self.address = address
        self.amount = amount
        self.includeScheme = includeScheme
    }
}

// TODO: Move to `BitcoinCashKit`
public struct BitcoinCashQRMetadata: CryptoAssetQRMetadata {
    public var address: String
    
    public var amount: String?
    
    public var paymentRequestUrl: String?
    
    public var absoluteString: String {
        let payload = BitcoinCashURLPayload(
            address: address,
            amount: amount,
            includeScheme: includeScheme
        )
        return payload.absoluteString
    }
    
    public var includeScheme: Bool = false
    
    public static var scheme: String {
        return AssetConstants.URLSchemes.bitcoinCash
    }
    
    public init(address: String, includeScheme: Bool = false) {
        self.address = address
        self.includeScheme = includeScheme
    }
    
    public init(address: String, amount: String?, includeScheme: Bool = false) {
        self.address = address
        self.amount = amount
        self.includeScheme = includeScheme
    }
}
