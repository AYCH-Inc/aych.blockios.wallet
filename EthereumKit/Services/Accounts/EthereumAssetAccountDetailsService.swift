//
//  EthereumAssetAccountDetailsService.swift
//  EthereumKit
//
//  Created by Jack on 19/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import BigInt

public class EthereumAssetAccountDetailsService: AssetAccountDetailsAPI {
            
    // MARK: - Properties

    private var balanceDetails: Single<BalanceDetailsResponse> {
        return bridge.address
            .flatMap(weak: self) { (self, address) -> Single<BalanceDetailsResponse> in
                 return self.client.balanceDetails(from: address)
            }
    }
    
    // MARK: - Injected
    
    private let bridge: EthereumWalletBridgeAPI
    private let client: APIClientProtocol
    
    // MARK: - Setup
    
    public init(with bridge: EthereumWalletBridgeAPI, client: APIClientProtocol) {
        self.bridge = bridge
        self.client = client
    }
    
    /// Streams the account details
    public func accountDetails(for accountID: String) -> Single<EthereumAssetAccountDetails> {
        return Single
            .zip(bridge.account, balanceDetails)
            .map { accountAndDetails -> EthereumAssetAccountDetails in
                return EthereumAssetAccountDetails(
                    account: accountAndDetails.0,
                    balance: accountAndDetails.1.cryptoValue,
                    nonce: accountAndDetails.1.nonce
                )
            }
    }
}
