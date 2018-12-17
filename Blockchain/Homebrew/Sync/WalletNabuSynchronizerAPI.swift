//
//  WalletNabuSynchronizerAPI.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Protocol definition for a component that can synchronize state between the wallet
/// and Nabu.
protocol WalletNabuSynchronizerAPI {

    /// Returns a signed retail token (a JWT token) from the wallet service. This token is typically
    /// used as a mechanism to transfer info from the wallet to other services (e.g. Nabu). The
    /// token expires in 1 minute.
    ///
    /// - Returns: a Single returning a SignedRetailTokenResponse
    func getSignedRetailToken() -> Single<SignedRetailTokenResponse>

    /// Syncs the current wallet state with Nabu. This works by requesting a signed
    /// retail token from the wallet (via getSignedRetailToken()) followed by sending
    /// that token to nabu. Syncing is typically performed when nabu should be updated
    /// when there is a state change in the wallet (e.g. email/phone verification).
    func sync(token: NabuSessionTokenResponse) -> Single<NabuUser>
}
