//
//  AssetAccountDetailsAPI.swift
//  PlatformKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// An API for fetching account `AssetAccountDetails`
public protocol AssetAccountDetailsAPI {
    associatedtype AccountDetails: AssetAccountDetails
    typealias AccountID = String
    
    /// This will fetch the `AssetAccount` given an `accountID`.
    /// - Parameters:
    /// - accountID: Can be the user's public key or asset specific accountID.
    func accountDetails(for accountID: AccountID) -> Maybe<AccountDetails>
}
