//
//  EmailVerificationServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol EmailVerificationServiceAPI {
    
    /// Waits until the email is verified by the user. Once the email is verified, the Completable sequence will complete
    /// This works by polling for `WalletSettings` periodically, and if the email is verified, it will call sync on the wallet-nabu synchronizer.
    func verifyEmail() -> Completable
    
    /// Cancells the waiting for email verification
    func cancel() -> Completable
}
