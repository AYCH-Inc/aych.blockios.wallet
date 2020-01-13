//
//  LegacyWalletAPI.swift
//  Blockchain
//
//  Created by Jack on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol LegacyWalletAPI: class {
        
    func createOrderPayment(withOrderTransaction orderTransaction: OrderTransactionLegacy,
                            completion: @escaping () -> Void,
                            success: ((String) -> Void)!,
                            error: @escaping (String) -> Void)
    
    func sendOrderTransaction(_ legacyAssetType: LegacyAssetType,
                              secondPassword: String?,
                              completion: @escaping () -> Void,
                              success: @escaping () -> Void,
                              error: @escaping (String) -> Void,
                              cancel: @escaping () -> Void)
    
    func needsSecondPassword() -> Bool
    
    func getReceiveAddress(forAccount account: Int32,
                           assetType: LegacyAssetType) -> String!
}

extension Wallet: LegacyWalletAPI {}
