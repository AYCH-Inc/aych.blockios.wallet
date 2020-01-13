//
//  AssetAccountRepositoryAPI.swift
//  PlatformKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// TODO: Change to `Single<Details>` / `Observable<Details>`
/// All assets should have a `AssetAccountRepository`. This is
/// separate from a `WalletAccountRepository`. 
public protocol AssetAccountRepositoryAPI {
    associatedtype Details: AssetAccountDetails
    
    /// The getter should return a `BehaviorRelay<Account?>`. It
    /// is supposed to be a computed property. It should default to what is
    /// cached, otherwise it will fetch the user's account details.
    var assetAccountDetails: Single<Details> { get }
    
    /// When the account details are fetched, you should call
    /// `privateAccountDetails.accept(account)` in order to cache the
    /// `AssetAccountDetails`.
    func currentAssetAccountDetails(fromCache: Bool) -> Single<Details>
}
