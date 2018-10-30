//
//  StellarAirdropRouter.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

struct EmptyNetworkResponse: Codable {
}

struct StellarRegisterCampaignPayload: Codable {
    let data: [String: String]
}

/// Router for handling the XLM airdrop flow
class StellarAirdropRouter {

    private let appSettings: BlockchainSettings.App
    private let kycCoordinator: KYCCoordinator
    private let repository: BlockchainDataRepository
    private let walletXlmAccountRepo: WalletXlmAccountRepository
    private let nabuAuthenticationService: NabuAuthenticationService

    private let disposables = CompositeDisposable()

    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        kycCoordinator: KYCCoordinator = KYCCoordinator.shared,
        repository: BlockchainDataRepository = BlockchainDataRepository.shared,
        walletXlmAccountRepo: WalletXlmAccountRepository = WalletXlmAccountRepository(),
        nabuAuthenticationService: NabuAuthenticationService = NabuAuthenticationService.shared
    ) {
        self.appSettings = appSettings
        self.kycCoordinator = kycCoordinator
        self.repository = repository
        self.walletXlmAccountRepo = walletXlmAccountRepo
        self.nabuAuthenticationService = nabuAuthenticationService
    }

    deinit {
        disposables.dispose()
    }

    /// Conditionally route the user to complete the Stellar airdrop flow if they have tapped on the
    /// Stellar airdrop link.
    ///
    /// The user will be prompted to complete the KYC flow if they have not yet already done so.
    /// This function will also register the user to the Stellar campaign.
    func routeIfNeeded() {
        // Only route if the user actually tapped on the airdrop link
        guard appSettings.didTapOnAirdropDeepLink else {
            return
        }

        // Only route if the user has not yet started KYC
        guard !appSettings.isCompletingKyc else {
            return
        }

        let nabuUser = repository.nabuUser.take(1)
        let xlmAccount = walletXlmAccountRepo.initializeMetadataMaybe().asObservable()
        let disposable = Observable.combineLatest(nabuUser, xlmAccount)
            .subscribeOn(MainScheduler.asyncInstance)
            .do(onNext: { [weak self] _, xlmAccount in
                self?.registerForCampaign(xlmAccount: xlmAccount)
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user, _ in
                guard let strongSelf = self else {
                    return
                }
                guard user.status == .none else {
                    return
                }
                strongSelf.kycCoordinator.start()
            }, onError: { error in
                Logger.shared.error("Cannot complete stellar airdrop: \(error.localizedDescription)")
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    private func registerForCampaign(xlmAccount: WalletXlmAccount) {
        // TODO: this endpoint is not yet deployed (should be deployed 10/30)
        let disposable = nabuAuthenticationService.getSessionToken()
            .flatMap { authToken -> Single<EmptyNetworkResponse> in
                guard let base = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
                    return Single.never()
                }
                guard let endpoint = URL.endpoint(base, pathComponents: ["register-campaign"], queryParameters: nil) else {
                    return Single.never()
                }
                let data = ["x-campaign-address": xlmAccount.publicKey]
                let payload = StellarRegisterCampaignPayload(data: data)
                guard let postPayload = try? JSONEncoder().encode(payload) else {
                    return Single.never()
                }
                return NetworkRequest.POST(
                    url: endpoint,
                    body: postPayload,
                    token: authToken.token,
                    type: EmptyNetworkResponse.self,
                    headers: ["X-CAMPAIGN": "sunriver"]
                )
            }.subscribe(onSuccess: { _ in
                Logger.shared.info("Successfully registered for sunriver campaign!")
            }, onError: { error in
                Logger.shared.error("Failed to register for campaign: \(error.localizedDescription)")
            })
        disposables.insertWithDiscardableResult(disposable)
    }
}
