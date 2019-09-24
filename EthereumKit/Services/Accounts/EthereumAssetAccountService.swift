//
//  EthereumAssetAccountService.swift
//  EthereumKit
//
//  Created by Jack on 03/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol EthereumAssetAccountServiceAPI {
    func fatchBalance(account: EthereumAssetAccount) -> Single<EthereumAssetAccountDetails>
}

final class EthereumAssetAccountService: EthereumAssetAccountServiceAPI {
    
    private let client: APIClientAPI
    
    public init(client: APIClientAPI) {
        self.client = client
    }
    
    // TODO: Possibly retrofit or deprecate
    public func fatchBalance(account: EthereumAssetAccount) -> Single<EthereumAssetAccountDetails> {
        
        // TODO: Fetch balance from
        // /account/{hash}/summary
        
        fatalError("Not yet implemented")
    }
}
