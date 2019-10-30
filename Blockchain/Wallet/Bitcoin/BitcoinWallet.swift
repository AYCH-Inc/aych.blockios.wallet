//
//  BitcoinWallet.swift
//  Blockchain
//
//  Created by Jack on 12/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import BitcoinKit

final class BitcoinWallet: NSObject {
    
    typealias Dispatcher = BitcoinJSInteropDispatcherAPI & BitcoinJSInteropDelegateAPI
    typealias WalletAPI = LegacyBitcoinWalletProtocol & LegacyWalletAPI & MnemonicAccessAPI
    
    @objc public var delegate: BitcoinJSInteropDelegateAPI {
        return dispatcher
    }
    
    var interopDispatcher: BitcoinJSInteropDispatcherAPI {
        return dispatcher
    }
    
    private weak var wallet: WalletAPI?
    
    private let dispatcher: Dispatcher
    
    @objc convenience public init(legacyWallet: Wallet) {
        self.init(wallet: legacyWallet)
    }
    
    init(wallet: WalletAPI, dispatcher: Dispatcher = BitcoinJSInteropDispatcher.shared) {
        self.wallet = wallet
        self.dispatcher = dispatcher
    }
    
    @objc public func setup(with context: JSContext) {
        
        context.setJsFunction(named: "objc_on_didGetDefaultBitcoinWalletIndexAsync" as NSString) { [weak self] defaultWalletIndex in
            self?.delegate.didGetDefaultWalletIndex(defaultWalletIndex)
        }
        context.setJsFunction(named: "objc_on_error_gettingDefaultBitcoinWalletIndexAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetDefaultWalletIndex(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_didGetBitcoinWalletsAsync" as NSString) { [weak self] accounts in
            self?.delegate.didGetAccounts(accounts)
        }
        context.setJsFunction(named: "objc_on_error_gettingBitcoinWalletsAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetAccounts(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_didGetHDWalletAsync" as NSString) { [weak self] wallet in
            self?.delegate.didGetHDWallet(wallet)
        }
        context.setJsFunction(named: "objc_on_error_gettingHDWalletAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetHDWallet(errorMessage: errorMessage)
        }
        
    }
    
    @objc public func walletDidLoad() {
        // TODO: This will be used once we implement native send
    }
    
}

extension BitcoinWallet: BitcoinWalletBridgeAPI {
    var hdWallet: Single<PayloadBitcoinHDWallet> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                return self.hdWallet(secondPassword: secondPassword)
            }
            .do(onNext: { hdWalletString in
                print(hdWalletString)
            })
            .map(weak: self) { (self, hdWalletString) -> PayloadBitcoinHDWallet in
                guard let data = hdWalletString.data(using: .utf8) else {
                    throw WalletError.unknown
                }
                let decodedHDWallet: PayloadBitcoinHDWallet
                do {
                    decodedHDWallet = try JSONDecoder().decode(PayloadBitcoinHDWallet.self, from: data)
                } catch {
                    throw error
                }
                return decodedHDWallet
            }
            .do(onNext: { payload in
                print(payload)
            })
            .debug("hdWalletDecoded", trimOutput: false)
    }
    
    var defaultWallet: Single<BitcoinWalletAccount> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<BitcoinWalletAccount> in
                self.bitcoinWallets(secondPassword: secondPassword)
                    .flatMap { wallets -> Single<BitcoinWalletAccount> in
                        self.defaultWalletIndex(secondPassword: secondPassword)
                            .map { index -> BitcoinWalletAccount in
                                guard let defaultWallet = wallets[safe: index] else {
                                    throw WalletError.unknown
                                }
                                return defaultWallet
                            }
                    }
            }

    }
    
    var wallets: Single<[BitcoinWalletAccount]> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<[BitcoinWalletAccount]> in
                return self.bitcoinWallets(secondPassword: secondPassword)
            }
    }
    
    private func bitcoinWallets(secondPassword: String?) -> Single<[BitcoinWalletAccount]> {
        return Single<String>.create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.bitcoinWallets(with: secondPassword, success: { accounts in
                    observer(.success(accounts))
                }, error: { errorMessage in
                    observer(.error(WalletError.unknown))
                })
                return Disposables.create()
            }
            .flatMap(weak: self) { (self, legacyWallets) -> Single<[BitcoinWalletAccount]> in
                guard let data = legacyWallets.data(using: .utf8) else {
                    throw WalletError.unknown
                }
                let decodedLegacyWallets: [PayloadBitcoinWalletAccount]
                do {
                    decodedLegacyWallets = try JSONDecoder().decode([PayloadBitcoinWalletAccount].self, from: data)
                } catch {
                    throw error
                }
                let decodedWallets = decodedLegacyWallets
                    .enumerated()
                    .map { arg -> BitcoinWalletAccount in
                        let (index, legacyAccount) = arg
                        return BitcoinWalletAccount(
                            index: index,
                            publicKey: legacyAccount.xpub,
                            label: legacyAccount.label,
                            archived: legacyAccount.archived
                        )
                    }
                return Single.just(decodedWallets)
            }
    }
    
    private func hdWallet(secondPassword: String?) -> Single<String> {
        return Single<String>.create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.hdWallet(with: secondPassword, success: { wallet in
                    observer(.success(wallet))
                }, error: { errorMessage in
                    observer(.error(WalletError.unknown))
                })
                return Disposables.create()
            }
    }
    
    private func defaultWalletIndex(secondPassword: String?) -> Single<Int> {
        return Single<Int>.create(weak: self) { (self, observer) -> Disposable in
            guard let wallet = self.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.bitcoinDefaultWalletIndex(with: secondPassword, success: { defaultWalletIndex in
                observer(.success(defaultWalletIndex))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        }
    }
}

extension BitcoinWallet: SecondPasswordPromptable {
    var legacyWallet: LegacyWalletAPI? {
        return wallet
    }
    
    var accountExists: Single<Bool> {
        return Single.just(true)
    }
}


extension BitcoinWallet: PasswordAccessAPI {
    public var password: Maybe<String> {
        guard let password = wallet?.password else {
            return Maybe.empty()
        }
        return Maybe.just(password)
    }
}

extension BitcoinWallet: MnemonicAccessAPI {
    var mnemonic: Maybe<Mnemonic> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonic
    }
    
    var mnemonicForcePrompt: Maybe<Mnemonic> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonicForcePrompt
    }
    
    var mnemonicPromptingIfNeeded: Maybe<Mnemonic> {
                guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonicPromptingIfNeeded
    }
    
    
}
