//
//  BitcoinURLPayload.swift
//  BitcoinKit
//
//  Created by Jack on 05/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Encapsulates the payload of a "bitcoin:" URL payload
@objc public class BitcoinURLPayload: NSObject, BIP21URI {
    
    public static var scheme: String {
        return AssetConstants.URLSchemes.bitcoin
    }
    
    @objc public var schemeCompat: String {
        return BitcoinURLPayload.scheme
    }
    
    @objc public var absoluteString: String {
        let prefix = includeScheme ? "\(BitcoinURLPayload.scheme):" : ""
        let uri = "\(prefix)\(address)"
        if let amount = amount {
            return "\(uri)?amount=\(amount)"
        }
        return uri
    }
    
    @objc public var address: String
    
    @objc public var amount: String?
    
    @objc public var includeScheme: Bool = false
    
    @objc public required init(address: String, amount: String?) {
        self.address = address
        self.amount = amount
    }
    
    @objc public required init(address: String, amount: String?, includeScheme: Bool = false) {
        self.address = address
        self.amount = amount
        self.includeScheme = includeScheme
    }
}

// TODO: Move to `BitcoinCashKit`
@objc public class BitcoinCashURLPayload: NSObject, BIP21URI {
    
    public static var scheme: String {
        return AssetConstants.URLSchemes.bitcoinCash
    }
    
    @objc public var schemeCompat: String {
        return BitcoinCashURLPayload.scheme
    }
    
    @objc public var absoluteString: String {
        let prefix = includeScheme ? "\(BitcoinCashURLPayload.scheme):" : ""
        let uri = "\(prefix)\(address)"
        if let amount = amount {
            return "\(uri)?amount=\(amount)"
        }
        return uri
    }
    
    @objc public var address: String
    
    @objc public var amount: String?
    
    @objc public var includeScheme: Bool = false
    
    @objc public required init(address: String, amount: String?) {
        self.address = address
        self.amount = amount
    }
    
    @objc public required init(address: String, amount: String?, includeScheme: Bool = false) {
        self.address = address
        self.amount = amount
        self.includeScheme = includeScheme
    }
}
