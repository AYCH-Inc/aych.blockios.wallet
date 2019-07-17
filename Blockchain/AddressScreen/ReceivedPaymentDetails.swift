//
//  ReceivedPaymentDetails.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Details about a received payment
struct ReceivedPaymentDetails {
    
    /// The amount
    let amount: String
    
    /// The type of the asset
    let asset: AssetType
    
    /// The address
    let address: String
}
