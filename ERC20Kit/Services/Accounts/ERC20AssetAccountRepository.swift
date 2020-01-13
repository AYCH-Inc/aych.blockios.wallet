//
//  ERC20AssetAccountRepository.swift
//  ERC20Kit
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxCocoa

public class AnyERC20AssetAccountRepository<Token: ERC20Token>: AssetAccountRepositoryAPI {
    public typealias Details = ERC20AssetAccountDetails
    
    private let assetAccountDetailsValue: Single<Details>
    private let currentAssetAccountDetailsClosure: (Bool) -> Single<ERC20AssetAccountDetails>
    
    public init<R: AssetAccountRepositoryAPI>(_ repository: R) where R.Details == Details {
        self.assetAccountDetailsValue = repository.assetAccountDetails
        self.currentAssetAccountDetailsClosure = repository.currentAssetAccountDetails
    }
    
    public var assetAccountDetails: Single<Details> {
        return assetAccountDetailsValue
    }
    
    public func currentAssetAccountDetails(fromCache: Bool) -> Single<Details> {
        return currentAssetAccountDetailsClosure(fromCache)
    }
}

open class ERC20AssetAccountRepository<Token: ERC20Token>: AssetAccountRepositoryAPI {
    public typealias Details = ERC20AssetAccountDetails
    
    public var assetAccountDetails: Single<Details> {
        return currentAssetAccountDetails(fromCache: true)
    }
    
    private var privateAccountDetails = BehaviorRelay<Details?>(value: nil)
    
    private let service: ERC20AssetAccountDetailsService<Token>
    
    public init(service: ERC20AssetAccountDetailsService<Token>) {
        self.service = service
    }
    
    public func currentAssetAccountDetails(fromCache: Bool) -> Single<Details> {
        let accountId = "0"
        return fetchAssetAccountDetails(for: accountId)
    }
        
    // MARK: Private Functions
    
    private func fetchAssetAccountDetails(for accountID: String) -> Single<Details> {
        return service.accountDetails(for: accountID)
            .do(onSuccess: { [weak self] account in
                self?.privateAccountDetails.accept(account)
            }
        )
    }
}
