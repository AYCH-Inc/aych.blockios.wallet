//
//  EthereumAssetAccountRepository.swift
//  EthereumKit
//
//  Created by Jack on 19/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift
import RxCocoa

open class EthereumAssetAccountRepository: AssetAccountRepositoryAPI {
    public typealias Details = EthereumAssetAccountDetails
    
    public var assetAccountDetails: Maybe<Details> {
        return currentAssetAccountDetails(fromCache: true)
    }
    
    private var privateAccountDetails = BehaviorRelay<Details?>(value: nil)
   
    private let service: EthereumAssetAccountDetailsService
    
    public init(service: EthereumAssetAccountDetailsService) {
        self.service = service
    }
    
    public func currentAssetAccountDetails(fromCache: Bool) -> Maybe<Details> {
        let accountId = "0"
        return fetchAssetAccountDetails(for: accountId)
    }
    
    // MARK: Private Functions
    
    fileprivate func fetchAssetAccountDetails(for accountID: String) -> Maybe<Details> {
        return service.accountDetails(for: accountID).do(onNext: { [weak self] account in
            self?.privateAccountDetails.accept(account)
        })
    }
}
