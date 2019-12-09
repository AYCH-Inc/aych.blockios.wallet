//
//  TabSwapping.swift
//  Blockchain
//
//  Created by Daniel Huri on 20/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

protocol TabSwapping {
    func switchToSend()
    func switchTabToSwap()
    func switchTabToReceive()
}

protocol CurrencyRouting {
    func toSend(_ currency: CryptoCurrency)
    func toReceive(_ currency: CryptoCurrency)
}
