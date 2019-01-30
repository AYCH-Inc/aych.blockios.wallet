//
//  StellarAirdropRegistrationService.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import StellarKit

struct StellarRegisterCampaignResponse: Codable {
    let message: String
}

struct StellarRegisterCampaignPayload: Codable {
    let data: [String: String]
    let newUser: Bool
}

protocol StellarAirdropRegistrationAPI {
    /// `autoRegisterIfNeeded` is used when the user authenticates. As soon as they
    /// authenticate we register them for the airdrop. This has unique logic that
    /// is different from traditional registration as it does not deep link the user
    /// to the KYC flow.
    func autoRegisterIfNeeded()
    func registerForCampaign(xlmAccount: StellarWalletAccount, nabuUser: NabuUser) -> Single<StellarRegisterCampaignResponse>
}

/// TODO: StellarAirdropRegistrationService knows too much. It shouldn't have
/// a `StellarWalletAccountRepository`, and `BlockchainDataRepository`, etc.
class StellarAirdropRegistrationService: StellarAirdropRegistrationAPI {

    private let appSettings: BlockchainSettings.App
    private let kycSettings: KYCSettingsAPI
    private let nabuAuthenticationService: NabuAuthenticationService
    private let stellarAccountRepository: StellarWalletAccountRepository
    private let repository: BlockchainDataRepository
    private let disposables = CompositeDisposable()

    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        kycSettings: KYCSettingsAPI = KYCSettings.shared,
        repository: BlockchainDataRepository = BlockchainDataRepository.shared,
        nabuAuthenticationService: NabuAuthenticationService = NabuAuthenticationService.shared,
        stellarAccountRepository: StellarWalletAccountRepository = StellarWalletAccountRepository(with: WalletManager.shared.wallet)
    ) {
        self.repository = repository
        self.appSettings = appSettings
        self.kycSettings = kycSettings
        self.nabuAuthenticationService = nabuAuthenticationService
        self.stellarAccountRepository = stellarAccountRepository
    }
    
    deinit {
        disposables.dispose()
    }
    
    func autoRegisterIfNeeded() {
        let nabuUser = repository.nabuUser.take(1)
        let xlmAccount = stellarAccountRepository.initializeMetadataMaybe().asObservable()
        let disposable = Observable.combineLatest(nabuUser, xlmAccount)
            .subscribeOn(MainScheduler.asyncInstance)
            .flatMap { [weak self] nabuUser, xlmAccount -> Observable<NabuUser> in
                guard let strongSelf = self else {
                    return Observable.empty()
                }
                
                guard let tiers = nabuUser.tiers else { return Observable.empty() }
                guard tiers.current == .tier2 else { return Observable.empty() }
                if let tags = nabuUser.tags, tags.sunriver != nil {
                    return Observable.empty()
                }
                
                return strongSelf.registerForCampaign(
                    xlmAccount: xlmAccount,
                    nabuUser: nabuUser
                    ).do(onSuccess: { response in
                        Logger.shared.info("Successfully registered for sunriver campaign. Message: '\(response.message)'")
                    })
                    .asObservable()
                    .map { _ -> NabuUser in
                        return nabuUser
                    }.catchError { error -> Observable<NabuUser> in
                        guard let httpError = error as? HTTPRequestServerError else { throw error }
                        guard case let .badStatusCode(_, payload) = httpError else { throw error }
                        guard let value = payload as? NabuNetworkError else { throw error }
                        if value.code == .campaignUserAlreadyRegistered {
                            return Observable.just(nabuUser)
                        } else {
                            throw error
                        }
                }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.appSettings.didRegisterForAirdropCampaignSucceed = true
                
                }, onError: { [weak self] error in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.appSettings.didRegisterForAirdropCampaignSucceed = false
                    
                    Logger.shared.error("Failed to register for campaign: \(error.localizedDescription)")
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    func registerForCampaign(xlmAccount: StellarWalletAccount, nabuUser: NabuUser) -> Single<StellarRegisterCampaignResponse> {
        return nabuAuthenticationService.getSessionToken()
            .flatMap { [weak self] authToken -> Single<StellarRegisterCampaignResponse> in
                guard let strongSelf = self else {
                    return Single.never()
                }
                return strongSelf.sendNetworkCall(xlmAccount: xlmAccount, nabuUser: nabuUser, authToken: authToken)
            }
    }

    private func sendNetworkCall(
        xlmAccount: StellarWalletAccount,
        nabuUser: NabuUser,
        authToken: NabuSessionTokenResponse
    ) -> Single<StellarRegisterCampaignResponse> {
        guard let base = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            return Single.never()
        }
        guard let endpoint = URL.endpoint(
            base,
            pathComponents: ["users", "register-campaign"],
            queryParameters: nil
        ) else {
            return Single.never()
        }
        let data = [DataParams.address: xlmAccount.publicKey]
        let isNewUser = (nabuUser.status == .none) && !kycSettings.isCompletingKyc
        let payload = StellarRegisterCampaignPayload(
            data: data,
            newUser: isNewUser
        )
        guard let postPayload = try? JSONEncoder().encode(payload) else {
            return Single.never()
        }
        return NetworkRequest.PUT(
            url: endpoint,
            body: postPayload,
            type: StellarRegisterCampaignResponse.self,
            headers: [
                "X-CAMPAIGN": "sunriver",
                HttpHeaderField.authorization: authToken.token
            ]
        )
    }

    struct DataParams {
        static let address = "x-campaign-address"
    }
}
