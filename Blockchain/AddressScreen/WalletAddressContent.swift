//
//  WalletAddressContent.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Content the represents an address on the data level
struct WalletAddressContent {
    
    /// The string representing the address
    let string: String
    
    /// The image representing the QR code of the address
    let image: UIImage
}
