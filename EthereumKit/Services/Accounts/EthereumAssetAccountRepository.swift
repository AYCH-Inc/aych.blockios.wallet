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
import RxRelay

open class EthereumAssetAccountRepository: AssetAccountRepositoryAPI {
    public typealias Details = EthereumAssetAccountDetails
    
    public var assetAccountDetails: Single<Details> {
        return currentAssetAccountDetails(fromCache: true)
    }
    
    private var privateAccountDetails = BehaviorRelay<Details?>(value: nil)
   
    private let service: EthereumAssetAccountDetailsService
    
    public init(service: EthereumAssetAccountDetailsService) {
        self.service = service
    }
    
    public func currentAssetAccountDetails(fromCache: Bool) -> Single<Details> {
        let accountId = "0"
        return fetchAssetAccountDetails(for: accountId)
    }
    
    // MARK: Private Functions
    
    fileprivate func fetchAssetAccountDetails(for accountID: String) -> Single<Details> {
        return service.accountDetails(for: accountID)
            .do(onSuccess: { [weak self] account in
                self?.privateAccountDetails.accept(account)
            }
        )
    }
}
