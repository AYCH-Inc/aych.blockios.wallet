//
//  AssetAccountRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PlatformKit
import EthereumKit
import StellarKit
import ERC20Kit
import BigInt

protocol AssetAccountRepositoryAPI {
    func accounts(for assetType: AssetType, fromCache: Bool) -> Maybe<[AssetAccount]>
    func defaultStellarAccount() -> AssetAccount?
    var accounts: Observable<[AssetAccount]> { get }
}

/// A repository for `AssetAccount` objects
// TICKET: [IOS-2087] - Integrate PlatformKit Account Repositories
// and Deprecate AssetAccountRepository
class AssetAccountRepository: AssetAccountRepositoryAPI {

    static let shared = AssetAccountRepository()

    private let wallet: Wallet
    private let xlmServiceProvider: XLMServiceProvider
    private let paxAccountRepository: ERC20AssetAccountRepository<PaxToken>
    private let ethereumAccountRepository: EthereumAssetAccountRepository
    private let ethereumWalletService: EthereumWalletServiceAPI
    private let stellarAccountService: StellarAccountAPI
    private var cachedAccounts = BehaviorRelay<[AssetAccount]?>(value: nil)
    private let disposables = CompositeDisposable()

    init(
        wallet: Wallet = WalletManager.shared.wallet,
        xlmServiceProvider: XLMServiceProvider = XLMServiceProvider.shared,
        paxServiceProvider: PAXServiceProvider = PAXServiceProvider.shared,
        ethereumServiceProvider: ETHServiceProvider = ETHServiceProvider.shared
    ) {
        self.wallet = wallet
        self.paxAccountRepository = paxServiceProvider.services.assetAccountRepository
        self.ethereumWalletService = paxServiceProvider.services.walletService
        self.xlmServiceProvider = xlmServiceProvider
        self.stellarAccountService = xlmServiceProvider.services.accounts
        self.ethereumAccountRepository = ethereumServiceProvider.services.assetAccountRepository
    }

    deinit {
        disposables.dispose()
    }

    // MARK: Public Methods
    
    func accounts(for assetType: AssetType, fromCache: Bool = true) -> Maybe<[AssetAccount]> {
        // A crash occurs in the for loop if wallet.getActiveAccountsCount returns 0
        // "Fatal error: Can't form Range with upperBound < lowerBound"
        if !wallet.isInitialized() {
            return Maybe.empty()
        }
        
        if assetType == .pax {
            if fromCache {
                return paxAccountRepository.assetAccountDetails.flatMap {
                    let balance = $0.balance.majorValue
                    Logger.shared.info("Balance for PAX: \(balance)")
                    let account = AssetAccount(
                        index: 0,
                        address: AssetAddressFactory.create(
                            fromAddressString: $0.account.accountAddress,
                            assetType: .pax
                        ),
                        balance: $0.balance,
                        name: $0.account.name
                    )
                    return Maybe.just([account])
                }
            } else {
                return paxAccountRepository.currentAssetAccountDetails(fromCache: false).flatMap {
                    let balance = $0.balance.majorValue
                    Logger.shared.info("Balance for PAX: \(balance)")
                    let account = AssetAccount(
                        index: 0,
                        address: AssetAddressFactory.create(
                            fromAddressString: $0.account.accountAddress,
                            assetType: .pax
                        ),
                        balance: $0.balance,
                        name: $0.account.name
                    )
                    return Maybe.just([account])
                }
            }
        }
        
        if fromCache {
            return accounts.asMaybe().flatMap { result -> Maybe<[AssetAccount]> in
                let cached = result.filter({ $0.address.assetType == assetType })
                return Maybe.just(cached)
            }
        }
        
        if assetType == .ethereum {
            return defaultEthereumAccount().flatMap({
                return Maybe.just([$0])
            })
        }
        
        if assetType == .stellar {
            if fromCache == false {
                return stellarAccountService.currentStellarAccount(fromCache: false)
                    .catchError { error -> Maybe<StellarAccount> in
                        /// Should Horizon go down or should we have an error when
                        /// retrieving the user's account details, we just want to return
                        /// a `Maybe.empty()`. If we return an error, the user will not be able
                        /// to see any of their available accounts in `Swap`. 
                        guard error is StellarServiceError else {
                            return Maybe.error(error)
                        }
                        return Maybe.empty()
                    }
                    .map({ return [$0.assetAccount] })
            }
            if let stellarAccount = defaultStellarAccount() {
                return Maybe.just([stellarAccount])
            }
            
            return Maybe.empty()
        }
        
        // Handle BTC and BCH
        // TODO pull in legacy addresses.
        // TICKET: IOS-1290
        var result: [AssetAccount] = []
        for index in 0...wallet.getActiveAccountsCount(assetType.legacy)-1 {
            let index = wallet.getIndexOfActiveAccount(index, assetType: assetType.legacy)
            if let assetAccount = AssetAccount.create(assetType: assetType, index: index, wallet: wallet) {
                result.append(assetAccount)
            }
        }
        return Maybe.just(result)
    }
    
    var accounts: Observable<[AssetAccount]> {
        guard let value = cachedAccounts.value else {
            return fetchAccounts().asObservable()
        }
        return Observable.just(value)
    }
    
    var fetchETHHistoryIfNeeded: Single<Void> {
        return ethereumWalletService.fetchHistoryIfNeeded
    }
    
    func fetchAccounts() -> Single<[AssetAccount]> {
        var observables: [Observable<[AssetAccount]>] = []
        AssetType.all.forEach {
            let observable = accounts(for: $0, fromCache: false)
                .ifEmpty(default: [])
                .asObservable()
            observables.append(observable)
        }
        return Single.create { observer -> Disposable in
            let disposable = Observable.zip(observables)
                .subscribeOn(MainScheduler.asyncInstance)
                .map({ $0.flatMap({ return $0 })})
                .subscribe(onNext: { [weak self] output in
                    guard let self = self else { return }
                    self.cachedAccounts.accept(output)
                    observer(.success(output))
                })
            self.disposables.insertWithDiscardableResult(disposable)
            return Disposables.create()
        }
    }

    func defaultAccount(for assetType: AssetType, fromCache: Bool = true) -> Maybe<AssetAccount> {
        if assetType == .ethereum {
            return defaultEthereumAccount()
        } else if assetType == .stellar {
            if let account = defaultStellarAccount() {
                return Maybe.just(account)
            } else {
                return Maybe.empty()
            }
        }
        let index = wallet.getDefaultAccountIndex(for: assetType.legacy)
        let account = AssetAccount.create(assetType: assetType, index: index, wallet: wallet)
        if let result = account {
            return Maybe.just(result)
        } else {
            return Maybe.empty()
        }
    }

    func defaultEthereumAccount() -> Maybe<AssetAccount> {
        guard let ethereumAddress = self.wallet.getEtherAddress(), self.wallet.hasEthAccount() else {
            Logger.shared.debug("This wallet has no ethereum address.")
            return Maybe.empty()
        }
        
        let fallback = EthereumAssetAccount(
            walletIndex: 0,
            accountAddress: ethereumAddress,
            name: LocalizationConstants.myEtherWallet
        )
        let details = EthereumAssetAccountDetails(
            account: fallback,
            balance: CryptoValue.zero(assetType: .ethereum)
        )
        
        return ethereumAccountRepository.assetAccountDetails
            .catchErrorJustReturn(details)
            .flatMap({ details -> Maybe<AssetAccount> in
                let account = AssetAccount(
                    index: 0,
                    address: AssetAddressFactory.create(
                        fromAddressString: details.account.accountAddress,
                        assetType: .ethereum
                    ),
                    balance: details.balance,
                    name: LocalizationConstants.myEtherWallet
                )
                return Maybe.just(account)
        })
    }

    func defaultStellarAccount() -> AssetAccount? {
        guard let stellarAccount = stellarAccountService.currentAccount else {
            return nil
        }
        return stellarAccount.assetAccount
    }
}

extension AssetAccount {

    /// Creates a new AssetAccount. This method only supports creating an AssetAccount for
    /// BTC or BCH. For ETH, use `defaultEthereumAccount`.
    static func create(assetType: AssetType, index: Int32, wallet: Wallet) -> AssetAccount? {
        guard let address = wallet.getReceiveAddress(forAccount: index, assetType: assetType.legacy) else {
            return nil
        }
        let name = wallet.getLabelForAccount(index, assetType: assetType.legacy)
        let balanceFromWalletObject = wallet.getBalanceForAccount(index, assetType: assetType.legacy)
        let balance: CryptoValue
        if assetType == .bitcoin || assetType == .bitcoinCash {
            let balanceLong = balanceFromWalletObject as? CUnsignedLongLong ?? 0
            let balanceDecimal = Decimal(balanceLong) / Decimal(Constants.Conversions.satoshi)
            let balanceString = (balanceDecimal as NSDecimalNumber).description(withLocale: Locale.current)
            let balanceBigUInt = BigUInt(balanceString, decimals: assetType.cryptoCurrency.maxDecimalPlaces) ?? 0
            let balanceBigInt = BigInt(balanceBigUInt)
            balance = CryptoValue.createFromMinorValue(balanceBigInt, assetType: assetType.cryptoCurrency)
        } else {
            let balanceString = balanceFromWalletObject as? String ?? "0"
            balance = CryptoValue.createFromMajorValue(string: balanceString, assetType: assetType.cryptoCurrency) ?? CryptoValue.zero(assetType: assetType.cryptoCurrency)
        }
        return AssetAccount(
            index: index,
            address: AssetAddressFactory.create(fromAddressString: address, assetType: assetType),
            balance: balance,
            name: name ?? ""
        )
    }
}

extension AssetAccountRepository {
    
    fileprivate func fetchAccountsStartingWithCache(
        cachedValue: BehaviorRelay<[AssetAccount]?>,
        networkValue: Single<[AssetAccount]>
        ) -> Observable<[AssetAccount]> {
        let networkObservable = networkValue.asObservable()
        guard let cached = cachedValue.value else {
            return networkObservable
        }
        return networkObservable.startWith(cached)
    }
    
    func nameOfAccountContaining(address: String) -> Maybe<String> {
        return accounts.asSingle().flatMapMaybe { output -> Maybe<String> in
            guard let result = output.first(where: { $0.address.address == address }) else {
                return Maybe.empty()
            }
            return Maybe.just(result.name)
        }
    }
}
