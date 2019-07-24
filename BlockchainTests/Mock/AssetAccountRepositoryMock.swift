//
//  AssetAccountRepositoryMock.swift
//  BlockchainTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class AssetAccountRepositoryMock: AssetAccountRepositoryAPI {
    func accounts(for assetType: AssetType, fromCache: Bool) -> Maybe<[AssetAccount]> {
        return Maybe.empty()
    }
    
    func defaultStellarAccount() -> AssetAccount? {
        return nil
    }
    
    var accounts: Observable<[AssetAccount]> {
        return Observable.empty()
    }
}
