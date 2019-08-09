//
//  BIP21URI.swift
//  PlatformKit
//
//  Created by AlexM on 12/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A URI scheme that conforms to BIP 21 (https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki)
/// TODO: Whenever `BitcoinKit` is added, we need to use this protocol for
/// QR metadata and QR responses. 
public protocol BIP21URI: CryptoAssetQRMetadata, AssetURLPayload {
    init(address: String, amount: String?)
}

extension BIP21URI {
    
    public init?(url: URL) {
        guard let urlScheme = url.scheme else {
            return nil
        }
        
        guard urlScheme == Self.scheme else {
            return nil
        }
        
        let address: String?
        let amount: String?
        let urlString = url.absoluteString
        let doubleSlash = "//"
        let colon = ":"
        
        if urlString.contains(doubleSlash) {
            let queryArgs = url.queryArgs
            
            address = url.host ?? queryArgs["address"]
            amount = queryArgs["amount"]
        } else if urlString.contains(colon) {
            // Handle web format (e.g. "scheme:1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
            guard let request = urlString.components(separatedBy: colon).last else {
                return nil
            }
            let requestComponents = request.components(separatedBy: "?")
            if let args = requestComponents.last {
                let queryArgs = args.queryArgs
                address = requestComponents.first ?? queryArgs["address"]
                amount = queryArgs["amount"]
            } else {
                address = requestComponents.first
                amount = nil
            }
        } else {
            address = nil
            amount = nil
        }
        
        guard address != nil else {
            return nil
        }
        
        self.init(address: address!, amount: amount)
    }
}
