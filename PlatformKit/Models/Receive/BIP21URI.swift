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
protocol BIP21URI: CryptoAssetQRMetadata {
    init(address: String, amount: String?)
}
