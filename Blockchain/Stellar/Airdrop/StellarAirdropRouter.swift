//
//  StellarAirdropRouter.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import StellarKit

/// Router for handling the XLM airdrop flow
class StellarAirdropRouter {

    private let appSettings: BlockchainSettings.App
    private let kycCoordinator: KYCCoordinator
    private let repository: BlockchainDataRepository
    private let registrationService: StellarAirdropRegistrationAPI

    private let disposables = CompositeDisposable()
    
    private let stellarWalletAccountRepository: StellarWalletAccountRepository

    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        kycCoordinator: KYCCoordinator = KYCCoordinator.shared,
        repository: BlockchainDataRepository = BlockchainDataRepository.shared,
        stellarWalletAccountRepository: StellarWalletAccountRepository = StellarWalletAccountRepository(with: WalletManager.shared.wallet),
        registrationService: StellarAirdropRegistrationAPI = StellarAirdropRegistrationService()
    ) {
        self.appSettings = appSettings
        self.kycCoordinator = kycCoordinator
        self.repository = repository
        self.registrationService = registrationService
        self.stellarWalletAccountRepository = stellarWalletAccountRepository
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

        // Only route if we did try to route already
        guard !appSettings.didAttemptToRouteForAirdrop else {
            return
        }

        let nabuUser = repository.nabuUser.take(1)
        let xlmAccount = stellarWalletAccountRepository.initializeMetadataMaybe().asObservable()
        let disposable = Observable.combineLatest(nabuUser, xlmAccount)
            .subscribeOn(MainScheduler.asyncInstance)
            .flatMap { [weak self] nabuUser, xlmAccount -> Observable<NabuUser> in
                guard let strongSelf = self else {
                    return Observable.empty()
                }
                return strongSelf.registerForCampaign(
                    xlmAccount: xlmAccount,
                    nabuUser: nabuUser
                ).catchError { error -> Observable<NabuUser> in
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

                strongSelf.appSettings.didAttemptToRouteForAirdrop = true
                strongSelf.appSettings.didRegisterForAirdropCampaignSucceed = true

                guard user.status == .none else {
                    return
                }
                strongSelf.kycCoordinator.start()
            }, onError: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.appSettings.didAttemptToRouteForAirdrop = true
                strongSelf.appSettings.didRegisterForAirdropCampaignSucceed = false

                Logger.shared.error("Failed to register for campaign: \(error.localizedDescription)")

                guard let httpError = error as? HTTPRequestServerError else { return }
                guard case let .badStatusCode(_, payload) = httpError else { return }
                guard let value = payload as? NabuNetworkError else {
                    AlertViewPresenter.shared.standardNotify(
                        message: LocalizationConstants.Errors.genericError,
                        title: LocalizationConstants.Errors.error
                    )
                    return
                }
                if value.code.isCampaignError {
                    AlertViewPresenter.shared.standardNotify(
                        message: LocalizationConstants.Stellar.XLMHasBeenClaimed,
                        title: LocalizationConstants.Stellar.ohNo
                    )
                    return
                }

                AlertViewPresenter.shared.standardNotify(
                    message: value.description,
                    title: LocalizationConstants.Errors.error
                )
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    private func registerForCampaign(xlmAccount: StellarWalletAccount, nabuUser: NabuUser) -> Observable<NabuUser> {
        return registrationService.registerForCampaign(xlmAccount: xlmAccount, nabuUser: nabuUser)
            .do(onSuccess: { response in
                Logger.shared.info("Successfully registered for sunriver campaign. Message: '\(response.message)'")
            })
            .asObservable()
            .map { _ -> NabuUser in
                return nabuUser
            }
    }
}
