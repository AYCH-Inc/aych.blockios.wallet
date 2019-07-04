//
//  LegacyWalletMock.swift
//  BlockchainTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class LegacyWalletMock: LegacyWalletAPI {
    func isWaitingOnEtherTransaction() -> Bool {
        return false
    }
    
    func createOrderPayment(withOrderTransaction orderTransaction: OrderTransactionLegacy, completion: @escaping () -> Void, success: ((String) -> Void)!, error: @escaping (String) -> Void) {
        success("")
        completion()
    }
    
    func sendOrderTransaction(_ legacyAssetType: LegacyAssetType, secondPassword: String?, completion: @escaping () -> Void, success: @escaping () -> Void, error: @escaping (String) -> Void, cancel: @escaping () -> Void) {
        success()
        completion()
    }
    
    func needsSecondPassword() -> Bool {
        return false
    }
    
    func getReceiveAddress(forAccount account: Int32, assetType: LegacyAssetType) -> String! {
        return ""
    }
}
