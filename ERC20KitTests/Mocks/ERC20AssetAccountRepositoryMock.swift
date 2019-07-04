//
//  ERC20AssetAccountRepositoryMock.swift
//  ERC20KitTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import ERC20Kit

class ERC20AssetAccountRepositoryMock: PlatformKit.AssetAccountRepositoryAPI {
    
    typealias Details = ERC20AssetAccountDetails
    
    var assetAccountDetails: Maybe<ERC20AssetAccountDetails> = Maybe.empty()
    
    func currentAssetAccountDetails(fromCache: Bool) -> Maybe<ERC20AssetAccountDetails> {
        return Maybe.empty()
    }
}
