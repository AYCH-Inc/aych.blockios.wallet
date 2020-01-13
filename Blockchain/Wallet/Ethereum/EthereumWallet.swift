//
//  EthereumWallet.swift
//  Blockchain
//
//  Created by Jack on 25/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import EthereumKit
import ERC20Kit
import RxSwift
import RxRelay
import BigInt

public class EthereumWallet: NSObject {
    
    typealias Dispatcher = EthereumJSInteropDispatcherAPI & EthereumJSInteropDelegateAPI
    
    typealias WalletAPI = LegacyEthereumWalletAPI & LegacyWalletAPI & MnemonicAccessAPI
    
    public var balanceObservable: Observable<CryptoValue> {
        return balanceRelay.asObservable()
    }
    
    public let balanceFetchTriggerRelay = PublishRelay<Void>()
        
    private let balanceRelay = PublishRelay<CryptoValue>()
    private let disposeBag = DisposeBag()
    
    @objc public var delegate: EthereumJSInteropDelegateAPI {
        return dispatcher
    }
    
    @available(*, deprecated, message: "making this public so tests will compile")
    public var interopDispatcher: EthereumJSInteropDispatcherAPI {
        return dispatcher
    }
    
    @available(*, deprecated, message: "Please don't use this. It's here only to support legacy code")
    @objc var legacyEthBalance: NSDecimalNumber = 0
    
    private lazy var credentialsProvider: WalletCredentialsProviding = WalletManager.shared.legacyRepository
    private weak var wallet: WalletAPI?
    private let walletOptionsService: WalletOptionsAPI
    
    /// This is lazy because we got a massive retain cycle, and injecting using `EthereumWallet` initializer
    /// overflows the function stack with initializers that call one another
    private lazy var dependencies: ETHDependencies = ETHServiceProvider.shared.services
    
    @objc private(set) var etherTransactions: [EtherTransaction] = []
    
    private static let defaultPAXAccount = ERC20TokenAccount(
        label: LocalizationConstants.SendAsset.myPaxWallet,
        contractAddress: PaxToken.contractAddress.rawValue,
        hasSeen: false,
        transactionNotes: [String: String]()
    )
            
    private var ethereumAccountExists: Bool?
        
    private let dispatcher: Dispatcher
    
    @objc convenience public init(legacyWallet: Wallet) {
        self.init(wallet: legacyWallet)
    }
    
    init(walletOptionsService: WalletOptionsAPI = WalletService.shared,
         wallet: WalletAPI,
         dispatcher: Dispatcher = EthereumJSInteropDispatcher.shared) {
        self.walletOptionsService = walletOptionsService
        self.wallet = wallet
        self.dispatcher = dispatcher
        super.init()
        balanceFetchTriggerRelay
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .flatMapLatest(weak: self) { (self, _) in
                return self.balance.asObservable()
            }
            .bind(to: balanceRelay)
            .disposed(by: disposeBag)
    }
    
    @objc public func setup(with context: JSContext) {
        context.setJsFunction(named: "objc_on_didGetERC20TokensAsync" as NSString) { [weak self] erc20TokenAccounts in
            self?.delegate.didGetERC20Tokens(erc20TokenAccounts)
        }
        context.setJsFunction(named: "objc_on_error_gettingERC20TokensAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetERC20Tokens(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_didSetERC20TokensAsync" as NSString) { [weak self] erc20TokenAccounts in
            self?.delegate.didSaveERC20Tokens()
        }
        context.setJsFunction(named: "objc_on_error_settingERC20TokensAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToSaveERC20Tokens(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_get_ether_address_success" as NSString) { [weak self] address in
            self?.delegate.didGetAddress(address)
        }
        context.setJsFunction(named: "objc_on_get_ether_address_error" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetAddress(errorMessage: errorMessage)
        }
                
        context.setJsFunction(named: "objc_on_didGetEtherAccountsAsync" as NSString) { [weak self] accounts in
            self?.delegate.didGetAccounts(accounts)
        }
        context.setJsFunction(named: "objc_on_error_gettingEtherAccountsAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetAccounts(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_recordLastTransactionAsync_success" as NSString) { [weak self] in
            self?.delegate.didRecordLastTransaction()
        }
        context.setJsFunction(named: "objc_on_recordLastTransactionAsync_error" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToRecordLastTransaction(errorMessage: errorMessage)
        }
    }
    
    @objc public func walletDidLoad() {
        walletLoaded()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    public func walletLoaded() -> Completable {
        guard let wallet = wallet else {
            return Completable.empty()
        }
        ethereumAccountExists = wallet.checkIfEthereumAccountExists()
        return saveDefaultPAXAccountIfNeeded()
    }
    
    private func saveDefaultPAXAccountIfNeeded() -> Completable {
        return erc20TokenAccounts
            .flatMapCompletable(weak: self) { (self, tokenAccounts) -> Completable in
                guard tokenAccounts[PaxToken.metadataKey] == nil else {
                    return Completable.empty()
                }
                return self.saveDefaultPAXAccount().asCompletable()
            }
    }
    
    private func saveDefaultPAXAccount() -> Single<ERC20TokenAccount> {
        let paxAccount = EthereumWallet.defaultPAXAccount
        return save(erc20TokenAccounts: [ PaxToken.metadataKey : paxAccount ])
            .asObservable()
            .flatMap(weak: self) { (self, _) -> Observable<ERC20TokenAccount> in
                return Observable.just(paxAccount)
            }
            .asSingle()
    }
}

extension EthereumWallet: ERC20BridgeAPI { 
    public func tokenAccount(for key: String) -> Single<ERC20TokenAccount?> {
        return erc20TokenAccounts
            .flatMap { tokenAccounts -> Single<ERC20TokenAccount?> in
                Single.just(tokenAccounts[key])
            }
    }
    
    public func save(erc20TokenAccounts: [String: ERC20TokenAccount]) -> Completable {
        return secondPasswordIfAccountCreationNeeded
            .asObservable()
            .flatMap(weak: self) { (self, secondPassword) -> Observable<Never> in
                return self.save(
                    erc20TokenAccounts: erc20TokenAccounts,
                    secondPassword: secondPassword
                )
                .asObservable()
            }
            .asCompletable()
    }
    
    public var erc20TokenAccounts: Single<[String: ERC20TokenAccount]> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<[String: ERC20TokenAccount]> in
                self.erc20TokenAccounts(secondPassword: secondPassword)
            }
    }
    
    public func memo(for transactionHash: String, tokenKey: String) -> Single<String?> {
        return erc20TokenAccounts
            .map { tokenAccounts -> ERC20TokenAccount? in
                tokenAccounts[tokenKey]
            }
            .map { tokenAccount -> String? in
                tokenAccount?.transactionNotes[transactionHash]
            }
    }
    
    public func save(transactionMemo: String, for transactionHash: String, tokenKey: String) -> Completable {
        return erc20TokenAccounts
            .flatMap { tokenAccounts -> Single<([String: ERC20TokenAccount], ERC20TokenAccount)> in
                guard let tokenAccount = tokenAccounts[tokenKey] else {
                    throw WalletError.failedToSaveMemo
                }
                return Single.just((tokenAccounts, tokenAccount))
            }
            .asObservable()
            .flatMap(weak: self) { (self, tuple) -> Observable<Never> in
                var (tokenAccounts, tokenAccount) = tuple
                _ = tokenAccounts.removeValue(forKey: tokenKey)
                tokenAccount.update(memo: transactionMemo, for: transactionHash)
                tokenAccounts[tokenKey] = tokenAccount
                return self.save(erc20TokenAccounts: tokenAccounts).asObservable()
            }
            .asCompletable()
    }
    
    private func save(erc20TokenAccounts: [String: ERC20TokenAccount], secondPassword: String?) -> Completable {
        return Completable.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            guard let jsonData = try? JSONEncoder().encode(erc20TokenAccounts) else {
                observer(.error(WalletError.unknown))
                return Disposables.create()
            }
            wallet.saveERC20Tokens(with: nil, tokensJSONString: jsonData.string, success: {
                observer(.completed)
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
    }
    
    private func erc20TokenAccounts(secondPassword: String? = nil) -> Single<[String: ERC20TokenAccount]> {
        return Single<[String: [String: Any]]>.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.erc20Tokens(with: secondPassword, success: { erc20Tokens in
                observer(.success(erc20Tokens))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
        .flatMap { erc20Accounts -> Single<[String: ERC20TokenAccount]> in
            let accounts: [String: ERC20TokenAccount] = erc20Accounts.decodeJSONObjects(type: ERC20TokenAccount.self)
            return Single.just(accounts)
        }
    }
}

extension EthereumWallet: EthereumWalletBridgeAPI {
    
    public var history: Single<Void> {
        return fetchHistory(fromCache: false)
    }
    
    public var balance: Single<CryptoValue> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<CryptoValue> in
                return self.fetchBalance(secondPassword: secondPassword)
            }
    }
    
    public var name: Single<String> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                return self.label(secondPassword: secondPassword)
            }
    }
    
    public var address: Single<String> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                return self.address(secondPassword: secondPassword)
            }
    }
    
    // TODO: IOS-2289 add test cases to it
    /** Fetch ether transactions using an injected service */
    public func fetchEthereumTransactions(using service: EthereumHistoricalTransactionService) -> Single<[EtherTransaction]> {
        return service.fetchTransactions()
            .map { [weak self] legacyTransactions in
                let result = legacyTransactions
                    .map { $0.legacyTransaction }
                    .compactMap { $0 }
                self?.etherTransactions = result
                return result
            }
    }
    
    public var account: Single<EthereumAssetAccount> {
        return wallets
            .flatMap { accounts -> Single<EthereumAssetAccount> in
                guard let defaultAccount = accounts.first else {
                    throw WalletError.unknown
                }
                let account = EthereumAssetAccount(
                    walletIndex: 0,
                    accountAddress: defaultAccount.publicKey,
                    name: defaultAccount.label ?? ""
                )
                return Single.just(account)
            }
    }
    
    /// Streams the nonce of the address
    public var nonce: Single<BigUInt> {
        return dependencies
            .assetAccountRepository
            .assetAccountDetails
            .map { BigUInt(integerLiteral: $0.nonce) }
    }
    
    /// Streams `true` if there is a prending transaction
    public var isWaitingOnTransaction: Single<Bool> {
        guard let wallet = wallet else {
            return .error(WalletError.notInitialized)
        }
        return Single
            .zip(
                wallet.hasLastTransactionDetails,
                dependencies.transactionService.hasTransactions
            )
            .map { (hasLastTransactionDetails, hasTransactions) -> Bool in
                /// Return `false` if no last transaction
                guard hasLastTransactionDetails else {
                    return false
                }
                /// Return `false` if transactions
                guard hasTransactions else {
                    return false
                }
                /// Return `true` to keep verifying whether the transaction has been processed / dropped
                return true
            }
            .flatMap(weak: self) { (self, shouldVerifyLastTransaction) -> Single<Bool> in
                guard shouldVerifyLastTransaction else {
                    return .just(false)
                }
                /// Analyze last transaction - whether it has been droppped by not being mined
                /// until the `lastTxFuse` time has passed, or alternately,
                /// it has been processed already
                return Single
                    .zip(
                        self.hasLastTransactionBeenProcessed,
                        self.isLastTransactionDropped
                    )
                    .map { (hasBeenProcessed, isDropped) -> Bool in
                        if hasBeenProcessed {
                            return false
                        }
                        // Transaction is has not been processed yet - check if it was dropped
                        return !isDropped
                    }
            }
    }

    /// If x time passed and transaction was not successfully mined,
    /// the last transaction will be deemed dropped and the account
    /// will be allowed to create a new transaction.
    private func isTransactionDropped(transactionDate: Date) -> Single<Bool> {
        return walletOptionsService.walletOptions
            .map { $0.ethereum.lastTxFuse }
            .map { TimeInterval($0) }
            .map { Date() > transactionDate.addingTimeInterval($0) }
    }
        
    public func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.recordLastEthereumTransaction(
                    transactionHash: transaction.transactionHash,
                    success: {
                        observer(.success(transaction))
                    },
                    error: { errorMessage in
                        observer(.error(WalletError.unknown))
                    }
                )
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
    }

    public func fetchHistory() -> Single<Void> {
        return fetchHistory(fromCache: false)
    }
    
    /// Check if the last transaction was processed
    private var hasLastTransactionBeenProcessed: Single<Bool> {
        guard let wallet = wallet else {
            return .error(WalletError.notInitialized)
        }
        return Single
            .zip(
                dependencies.transactionService.transactions,
                 wallet.lastEthereumTransactionDetails
            )
            .map { (transactions, lastTxDetails) -> Bool in
                guard let lastTxHash = lastTxDetails?.hash else {
                    return false
                }
                return transactions.contains { $0.transactionHash == lastTxHash }
            }
    }
    
    /// Check if the last transaction was dropped
    private var isLastTransactionDropped: Single<Bool> {
        guard let wallet = wallet else {
            return .error(WalletError.notInitialized)
        }
        return wallet.lastEthereumTransactionDetails
            .flatMap(weak: self) { (self, lastTransactionDetails) -> Single<Bool> in
                guard let lastTransactionDetails = lastTransactionDetails else {
                    return .just(false)
                }
                return self.isTransactionDropped(transactionDate: lastTransactionDetails.date)
            }
    }
    
    private func fetchBalance(secondPassword: String? = nil) -> Single<CryptoValue> {
        return dependencies.assetAccountRepository.assetAccountDetails
            .map { $0.balance }
            // TODO: This side effect is necessary for backward compat. since the relevant JS logic has been removed
            .do(onSuccess: { [weak self] cryptoValue in
                self?.legacyEthBalance = NSDecimalNumber(decimal: cryptoValue.majorValue)
            })
    }
    
    private func accounts(secondPassword: String? = nil) -> Single<EthereumAssetAccount> {
        return wallets.flatMap { wallets -> Single<EthereumAssetAccount> in
            guard let defaultAccount = wallets.first else {
                throw WalletError.unknown
            }
            let account = EthereumAssetAccount(
                walletIndex: 0,
                accountAddress: defaultAccount.publicKey,
                name: defaultAccount.label ?? ""
            )
            return Single.just(account)
        }
    }
    
    private func label(secondPassword: String? = nil) -> Single<String> {
        return Single<String>
            .create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.getLabelForEthereumAccount(with: secondPassword, success: { label in
                    observer(.success(label))
                }, error: { errorMessage in
                    observer(.error(WalletError.unknown))
                })
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
    }
    
    private func address(secondPassword: String? = nil) -> Single<String> {
        return Single<String>
            .create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.getEthereumAddress(with: secondPassword, success: { address in
                    observer(.success(address))
                }, error: { errorMessage in
                    observer(.error(WalletError.unknown))
                })
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
    }
                
    private func fetchHistory(fromCache: Bool) -> Single<Void> {
        let transactions: Single<[EthereumHistoricalTransaction]>
        if fromCache {
            transactions = dependencies.transactionService.transactions
        } else {
            transactions = dependencies.transactionService.fetchTransactions()
        }
        return transactions.mapToVoid()
    }
}

extension EthereumWallet: MnemonicAccessAPI {
    public var mnemonic: Maybe<String> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonic
    }
    
    public var mnemonicForcePrompt: Maybe<String> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonicForcePrompt
    }
    
    public var mnemonicPromptingIfNeeded: Maybe<String> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonicPromptingIfNeeded
    }
}

extension EthereumWallet: PasswordAccessAPI {
    public var password: Maybe<String> {
        guard let password = credentialsProvider.legacyPassword else {
            return Maybe.empty()
        }
        return Maybe.just(password)
    }
}

extension EthereumWallet: EthereumWalletAccountBridgeAPI {
    public func save(keyPair: EthereumKeyPair, label: String) -> Completable {
        guard let base58PrivateKey = keyPair.privateKey.base58EncodedString else {
            return Completable.error(WalletError.failedToSaveKeyPair("Invalid private key"))
        }
        return Completable.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.saveEthereumAccount(with: base58PrivateKey, label: label, success: {
                observer(.completed)
            }, error: { errorMessage in
                observer(.error(WalletError.failedToSaveKeyPair(errorMessage)))
            })
            return Disposables.create()
        })
    }
    
    public var wallets: Single<[EthereumWalletAccount]> {
        return secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<[EthereumWalletAccount]> in
                return self.ethereumWallets(secondPassword: secondPassword)
            }
    }
    
    private func ethereumWallets(secondPassword: String?) -> Single<[EthereumWalletAccount]> {
        return Single<[[String: Any]]>.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.ethereumAccounts(with: secondPassword, success: { accounts in
                observer(.success(accounts))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
        .flatMap(weak: self) { (self, legacyAccounts) -> Single<[EthereumWalletAccount]> in
            let accounts = legacyAccounts
                .decodeJSONObjects(type: LegacyEthereumWalletAccount.self)
                .enumerated()
                .map { index, account -> EthereumWalletAccount in
                    return EthereumWalletAccount(
                        index: index,
                        publicKey: account.addr,
                        label: account.label,
                        archived: false
                    )
                }
            return Single.just(accounts)
        }
    }
    

}

extension EthereumWallet: SecondPasswordPromptable {
    var legacyWallet: LegacyWalletAPI? {
        return wallet
    }
    
    var accountExists: Single<Bool> {
        guard let ethereumAccountExists = ethereumAccountExists else {
            return Single.error(WalletError.notInitialized)
        }
        return Single.just(ethereumAccountExists)
    }
}
