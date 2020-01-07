//
//  CryptoCurrency+Conveniences.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/28/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public extension CryptoCurrency {
    var brandColor: UIColor {
        switch self {
        case .bitcoin:
            return .bitcoin
        case .ethereum:
            return .ethereum
        case .bitcoinCash:
            return .bitcoinCash
        case .pax:
            return .pax
        case .stellar:
            return .stellar
        }
    }
    
    var logo: UIImage {
        return UIImage(named: logoImageName)!
    }
    
    var logoImageName: String {
        switch self {
        case .bitcoin:
            return "filled_btc_small"
        case .bitcoinCash:
            return "filled_bch_large"
        case .ethereum:
            return "filled_eth_large"
        case .pax:
            return "filled_pax_large"
        case .stellar:
            return "filled_xlm_large"
        }
    }
}
