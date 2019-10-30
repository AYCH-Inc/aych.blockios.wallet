//
//  BlockstackService.swift
//  Blockchain
//
//  Created by Jack on 29/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import BitcoinKit

protocol BlockstackServiceAPI {
    
    var registerForCampaignIfNeeded: Completable { get }
}

final class BlockstackService: BlockstackServiceAPI {
    
    // MARK: - Public properties
    
    var registerForCampaignIfNeeded: Completable {
        return dataRepository.fetchNabuUser()
            .flatMapCompletable(weak: self) { (self, nabuUser) -> Completable in
                guard
                    nabuUser.isGoldTierVerified,
                    !nabuUser.isBlockstackAirdropRegistered
                else {
                    return .empty()
                }
                return self.register(nabuUser: nabuUser)
            }
    }
    
    // MARK: - Private properties
    
    private let dataRepository: BlockchainDataRepository
    private let airdropRegistration: AirdropRegistrationAPI
    private let nabuAuthenticationService: NabuAuthenticationServiceAPI
    private let blockStackAccountRepository: BlockstackAccountAPI
    private let kycSettings: KYCSettingsAPI
    
    // MARK: - Init
    
    init(dataRepository: BlockchainDataRepository = .shared,
         airdropRegistration: AirdropRegistrationAPI = AirdropRegistrationService(),
         nabuAuthenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         blockStackAccountRepository: BlockstackAccountAPI = BlockstackAccountRepository(with: WalletManager.shared.wallet.bitcoin),
         kycSettings: KYCSettingsAPI = KYCSettings.shared) {
        self.dataRepository = dataRepository
        self.airdropRegistration = airdropRegistration
        self.nabuAuthenticationService = nabuAuthenticationService
        self.blockStackAccountRepository = blockStackAccountRepository
        self.kycSettings = kycSettings
    }
    
    // MARK: - Private methods
    
    private func register(nabuUser: NabuUser) -> Completable {
        return Single.zip(
                nabuAuthenticationService.getSessionToken(),
                blockStackAccountRepository.accountAddress
            )
            .flatMap(weak: self) { (self, tuple) -> Single<AirdropRegistrationResponse> in
                let (tokenResponse, accountAddress) = tuple
                let isNewUser =
                       (nabuUser.status == .none)
                    && !self.kycSettings.isCompletingKyc
                let request = AirdropRegistrationRequest(
                    authToken: tokenResponse.token,
                    publicKey: accountAddress.rawValue,
                    campaignIdentifier: .blockstack,
                    isNewUser: isNewUser
                )
                return self.airdropRegistration
                    .submitRegistrationRequest(request)
            }
            .asCompletable()
    }
}
