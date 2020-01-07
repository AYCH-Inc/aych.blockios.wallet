//
//  TriageCryptoCurrency.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 30/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public extension TriageCryptoCurrency {
    
    var logoImageName: String {
        switch self {
        case .blockstack:
            return "filled_stx_large"
        case .supported(let currency):
            return currency.logoImageName
        }
    }
    
    var logoImage: UIImage {
        return UIImage(named: logoImageName)!
    }
}
