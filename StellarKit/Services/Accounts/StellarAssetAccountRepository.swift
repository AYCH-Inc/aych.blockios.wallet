//
//  StellarAssetAccountRepository.swift
//  StellarKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift
import RxCocoa

open class StellarAssetAccountRepository: AssetAccountRepositoryAPI {
    public typealias Details = StellarAssetAccountDetails
    
    public var assetAccountDetails: Maybe<Details> {
        if let cached = privateAccountDetails.value {
            return Maybe.just(cached)
        }
        guard let walletAccount = walletRepository.defaultAccount else {
            return Maybe.error(StellarServiceError.noXLMAccount)
        }
        return fetchAssetAccountDetails(walletAccount.publicKey)
    }
    
    fileprivate let service: StellarAssetAccountDetailsService
    fileprivate let walletRepository: StellarWalletAccountRepository
    
    // MARK: Lifecycle
    
    public init(service: StellarAssetAccountDetailsService,
                walletRepository: StellarWalletAccountRepository) {
        self.service = service
        self.walletRepository = walletRepository
    }
    
    deinit {
        disposable?.dispose()
        disposable = nil
    }
    
    // MARK: Private Properties
    
    fileprivate var disposable: Disposable?
    fileprivate var privateAccountDetails = BehaviorRelay<Details?>(value: nil)
    
    // MARK: AssetAccountRepositoryAPI
    
    public func currentAssetAccountDetails(fromCache: Bool) -> Maybe<Details> {
        if let cached = privateAccountDetails.value, fromCache == true {
            return Maybe.just(cached)
        }
        guard let walletAccount = walletRepository.defaultAccount else {
            return Maybe.error(StellarServiceError.noXLMAccount)
        }
        let accountID = walletAccount.publicKey
        return service.accountDetails(for: accountID).do(onNext: { [weak self] account in
            self?.privateAccountDetails.accept(account)
        })
    }
    
    // MARK: Private Functions
    
    fileprivate func fetchAssetAccountDetails(_ accountID: String) -> Maybe<Details> {
        return service.accountDetails(for: accountID).do(onNext: { [weak self] account in
            self?.privateAccountDetails.accept(account)
        })
    }
}
