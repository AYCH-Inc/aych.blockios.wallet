//
//  SecondPasswordPromptable.swift
//  Blockchain
//
//  Created by Jack on 18/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol SecondPasswordPromptable: class {
    var legacyWallet: LegacyWalletAPI? { get }
    var accountExists: Single<Bool> { get }
    
    var secondPasswordNeeded: Single<Bool> { get }
    var secondPasswordIfNeeded: Single<String?> { get }
    var promptForSecondPassword: Single<String> { get }
    var secondPasswordIfAccountCreationNeeded: Single<String?> { get }
}

extension SecondPasswordPromptable {
    
    @available(*, deprecated, message: "The implementation of second password prompting will be deprecated soon")
    var secondPasswordNeeded: Single<Bool> {
        guard let wallet = legacyWallet else {
            return Single.error(WalletError.notInitialized)
        }
        return Single.just(wallet.needsSecondPassword())
    }
    
    @available(*, deprecated, message: "The implementation of second password prompting will be deprecated soon")
    var secondPasswordIfNeeded: Single<String?> {
        return secondPasswordNeeded
            .flatMap { [weak self] needed -> Single<String?> in
                guard let self = self else { throw WalletError.unknown }
                guard !needed else {
                    return self.promptForSecondPassword
                        .map { password -> String? in
                            return password
                        }
                }
                return Single.just(nil)
            }
    }
    
    @available(*, deprecated, message: "The implementation of second password prompting will be deprecated soon")
    var promptForSecondPassword: Single<String> {
        return Single.create(subscribe: { observer -> Disposable in
            AuthenticationCoordinator.shared.showPasswordConfirm(
                withDisplayText: LocalizationConstants.Authentication.secondPasswordDefaultDescription,
                headerText: LocalizationConstants.Authentication.secondPasswordRequired,
                validateSecondPassword: true,
                confirmHandler: { password in
                    observer(.success(password))
                },
                dismissHandler: {
                    observer(.error(WalletError.unknown))
                }
            )
            return Disposables.create()
        })
        .subscribeOn(MainScheduler.instance)
    }
    
    @available(*, deprecated, message: "The implementation of second password prompting will be deprecated soon")
    var secondPasswordIfAccountCreationNeeded: Single<String?> {
        return accountExists
            .flatMap(weak: self) { (self, accountExists) -> Single<String?> in
                guard accountExists else {
                    return self.secondPasswordIfNeeded
                }
                return Single.just(nil)
            }
    }
}
