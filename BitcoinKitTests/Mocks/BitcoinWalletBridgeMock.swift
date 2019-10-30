//
//  BitcoinWalletBridgeMock.swift
//  BitcoinKitTests
//
//  Created by Jack on 22/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
@testable import BitcoinKit

class BitcoinWalletBridgeMock: BitcoinWalletBridgeAPI {
    
    enum MockError: Error {
        case error
    }
    
    var hdWalletValue: Single<PayloadBitcoinHDWallet> = Single.error(MockError.error)
    var hdWallet: Single<PayloadBitcoinHDWallet> {
        return hdWalletValue
    }
    
    var defaultWalletValue: Single<BitcoinWalletAccount> = Single.error(MockError.error)
    var defaultWallet: Single<BitcoinWalletAccount> {
        return defaultWalletValue
    }
    
    var walletsValue: Single<[BitcoinWalletAccount]> = Single.just([])
    var wallets: Single<[BitcoinWalletAccount]> {
        return walletsValue
    }
}
