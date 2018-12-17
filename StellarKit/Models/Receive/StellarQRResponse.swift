//
//  StellarQRResponse.swift
//  StellarKit
//
//  Created by Alex McGregor on 12/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import stellarsdk

struct StellarQRResponse: SEP7URI {
    var address: String
    var absoluteString: String {
        let uriScheme = URIScheme()
        var amountInDecimal: Decimal?
        if let amount = amount {
            amountInDecimal = Decimal(string: amount)
        }
        return uriScheme.getPayOperationURI(accountID: address, amount: amountInDecimal)
    }
    
    var amount: String?
    
    static var scheme: String {
        return "web+stellar"
    }
    
    init?(url: URL) {
        guard StellarQRResponse.scheme == url.scheme else { return nil }
        
        var destination: String? = url.absoluteString
        var paymentAmount: String?
        let urlString = url.absoluteString
        
        if let argsString = urlString.components(separatedBy: "\(StellarQRMetadata.scheme):\(PayOperation)").last {
            let queryArgs = argsString.queryArgs
            destination = queryArgs["\(PayOperationParams.destination)"]
            paymentAmount = queryArgs["\(PayOperationParams.amount)"]
        }
        
        guard let value = destination else { return nil }
        
        self.address = value
        self.amount = paymentAmount
    }
}
