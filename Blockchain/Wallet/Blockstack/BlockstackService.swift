//
//  BlockstackService.swift
//  Blockchain
//
//  Created by Jack on 29/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import ToolKit
import NetworkKit
import PlatformKit
import BitcoinKit

enum BlockstackErrorEvent: AnalyticsEvent {
    case failedToRegister(Error)
    
    var name: String {
        return "blockstack_registration_error"
    }
    
    var params: [String : String]? {
        switch self {
        case .failedToRegister(let error):
            return [ "error_message" : error.localizedDescription ]
        }
    }
}

protocol BlockstackServiceAPI {
    
    var registerForCampaignIfNeeded: Completable { get }
}

final class BlockstackService: BlockstackServiceAPI, AnalyticsEventRecordable {
    
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
            .do(onError: { [weak self] error in
                self?.eventRecorder?.record(event: BlockstackErrorEvent.failedToRegister(error))
            })
    }
    
    // MARK: - Recordable
    
    public func use(eventRecorder: AnalyticsEventRecording) {
        self.eventRecorder = eventRecorder
    }
    
    // MARK: - Private properties
    
    private let dataRepository: BlockchainDataRepository
    private let airdropRegistration: AirdropRegistrationAPI
    private let nabuAuthenticationService: NabuAuthenticationServiceAPI
    private let blockStackAccountRepository: BlockstackAccountAPI
    private let kycSettings: KYCSettingsAPI
    private var eventRecorder: AnalyticsEventRecording?
    
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
