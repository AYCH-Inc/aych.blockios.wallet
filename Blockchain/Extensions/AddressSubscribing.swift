//
//  AddressSubscribing.swift
//  Blockchain
//
//  Created by Daniel Huri on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol AssetAddressSubscribing {
    
    /// Subscribes to payments to an asset address
    func subscribe(to address: String, asset: AssetType, addressType: AssetAddressType)
}
