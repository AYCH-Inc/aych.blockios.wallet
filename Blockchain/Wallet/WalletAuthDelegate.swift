//
//  WalletAuthDelegate.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

/// Protocol definition for a delegate for authentication-related wallet callbacks
protocol WalletAuthDelegate: class {
    /// Callback invoked when the wallet successfully decrypts
    func didDecryptWallet(guid: String?, sharedKey: String?, password: String?)

    /// Callback invoked when an error occurred with authenticating
    func authenticationError(error: AuthenticationError?)

    /// Callback invoked when the user has successfully authenticated
    func authenticationCompleted()
}
