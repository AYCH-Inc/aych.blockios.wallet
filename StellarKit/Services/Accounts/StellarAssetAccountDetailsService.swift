//
//  StellarAssetAccountDetailsService.swift
//  StellarKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import stellarsdk

public class StellarAssetAccountDetailsService: AssetAccountDetailsAPI {
    public typealias AccountDetails = StellarAssetAccountDetails
    
    private let configuration: StellarConfiguration
    fileprivate lazy var service: AccountService = {
        configuration.sdk.accounts
    }()
    
    public init(configuration: StellarConfiguration) {
        self.configuration = configuration
    }
    
    public func accountDetails(for accountID: AccountID) -> Maybe<AccountDetails> {
        return accountResponse(for: accountID).map { response -> AccountDetails in
            return response.toAssetAccountDetails()
            }.catchError { error in
                // If the network call to Horizon fails due to there not being a default account (i.e. account is not yet
                // funded), catch that error and return a StellarAccount with 0 balance
                if let stellarError = error as? StellarServiceError, stellarError == .noDefaultAccount {
                    return Single.just(AccountDetails.unfunded(accountID: accountID))
                }
                throw error
            }.asMaybe()
    }
    
    // MARK: Private Functions
    
    fileprivate func accountResponse(for accountID: AccountID) -> Single<AccountResponse> {
        return Single<AccountResponse>.create { [weak self] event -> Disposable in
            self?.service.getAccountDetails(accountId: accountID, response: { response -> (Void) in
                switch response {
                case .success(details: let details):
                    event(.success(details))
                case .failure(error: let error):
                    event(.error(error.toStellarServiceError()))
                }
            })
            return Disposables.create()
        }
    }
}
