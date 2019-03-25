//
//  LegacyEthereumWalletMock.swift
//  BlockchainTests
//
//  Created by Jack on 26/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
@testable import PlatformKit
@testable import EthereumKit
@testable import PlatformUIKit
@testable import Blockchain

class MockLegacyEthereumWallet: LegacyEthereumWalletProtocol {
    enum MockLegacyEthereumWalletError: Error {
        case notInitialized
    }
    
    var getEtherAddressCompletion: NewResult<String, MockLegacyEthereumWalletError> = .success("address")
    func getEtherAddress(success: @escaping (String) -> Void, error: @escaping (String?) -> Void) {
        switch getEtherAddressCompletion {
        case .success(let value):
            success(value)
        case .failure(let e):
            error("\(e.localizedDescription)")
        }
    }
    
    var labelForAccount: String?
    func getLabelForAccount(_ account: Int32, assetType: LegacyAssetType) -> String! {
        return labelForAccount ?? "account: \(account), assetType: \(assetType.rawValue)"
    }
    
    var getEthBalanceTruncatedNumberValue: NSNumber? = NSNumber(value: 1337)
    func getEthBalanceTruncatedNumber() -> NSNumber? {
        return getEthBalanceTruncatedNumberValue
    }
    
    var ethTransactions: [EtherTransaction]? = [
        EthereumTransaction(
            identifier: "identifier",
            fromAddress: EthereumTransaction.Address(publicKey: "fromAddress.publicKey"),
            toAddress: EthereumTransaction.Address(publicKey: "toAddress.publicKey"),
            direction: .credit,
            amount: "amount",
            transactionHash: "transactionHash",
            createdAt: Date(),
            fee: 1,
            memo: "memo",
            confirmations: 12
        ).legacyTransaction
    ].compactMap { $0 }
    func getEthTransactions() -> [EtherTransaction]? {
        return ethTransactions
    }
}
