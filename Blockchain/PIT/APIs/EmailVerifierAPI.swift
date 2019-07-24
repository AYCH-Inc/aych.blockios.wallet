//
//  EmailVerifierAPI.swift
//  Blockchain
//
//  Created by AlexM on 7/9/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

protocol EmailVerifierAPI {
    func sendVerificationEmail(to email: EmailAddress, contextParameter: ContextParameter?) -> Completable
    func pollWalletSettings() -> Observable<WalletSettings>
    func waitForEmailVerification() -> Observable<Bool>
    var userEmail: Single<Email> { get }
}

protocol EmailVerificationInterface: class {
    func updateLoadingViewVisibility(_ visibility: Visibility)
    func showError(message: String)
    func sendEmailVerificationSuccess()
}
