//
//  StellarQRMetadata.swift
//  StellarKit
//
//  Created by Alex McGregor on 12/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import stellarsdk

public struct StellarQRMetadata: CryptoAssetQRMetadata {
    public var address: String
    public var amount: String?
    public var absoluteString: String {
        var value: Decimal?
        if let amount = amount {
            value = Decimal(string: amount)
        }
        return URIScheme().getPayOperationURI(accountID: address, amount: value)
    }
    
    public var includeScheme: Bool = false
    
    public static var scheme: String {
        return "web+stellar"
    }
    
    public init(address: String, amount: String?) {
        self.address = address
        self.amount = amount
    }
}
