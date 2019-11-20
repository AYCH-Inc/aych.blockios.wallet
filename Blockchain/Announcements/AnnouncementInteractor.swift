//
//  AnnouncementInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import ERC20Kit
import EthereumKit

/// The announcement interactor cross all the preliminary data
/// that is required to display announcements to the user
final class AnnouncementInteractor: AnnouncementInteracting {
    
    // MARK: - Services
    
    /// Dispatch queue
    private let dispatchQueueName = "announcements-interaction-queue"
    
    private let wallet: WalletProtocol
    private let dataRepository: BlockchainDataRepository
    private let exchangeService: ExchangeService
    private let variantFetcher: FeatureVariantFetching
    private let paxTransactionService: AnyERC20HistoricalTransactionService<PaxToken>
    
    /// Returns announcement preliminary data, according to which the relevant
    /// announcement will be displayed
    var preliminaryData: Single<AnnouncementPreliminaryData> {
        guard wallet.isInitialized() else {
            return Single.error(AnnouncementError.uninitializedWallet)
        }
        
        let countries = dataRepository.countries
            .asObservable()
        
        let hasPaxTransactions = paxTransactionService.hasTransactions
            .asObservable()
        
        let hasTrades = exchangeService.hasExecutedTrades()
            .asObservable()

        let pitLinkingCardVariant = variantFetcher
            .fetchTestingVariant(for: .pitAnnouncementVariant)
            .catchErrorJustReturn(.variantA)
            .asObservable()
            
        return Observable
            .zip(dataRepository.nabuUser,
                 dataRepository.tiers,
                 hasTrades,
                 hasPaxTransactions,
                 countries,
                 pitLinkingCardVariant)
            .subscribeOn(SerialDispatchQueueScheduler(internalSerialQueueName: dispatchQueueName))
            .observeOn(MainScheduler.instance)
            .map { (user, tiers, hasTrades, hasPaxTransactions, countries, pitLinkingCardVariant) -> AnnouncementPreliminaryData in
                return AnnouncementPreliminaryData(
                    user: user,
                    tiers: tiers,
                    hasTrades: hasTrades,
                    hasPaxTransactions: hasPaxTransactions,
                    countries: countries,
                    pitLinkingCardVariant: pitLinkingCardVariant
                )
            }
            .asSingle()
    }
    
    // MARK: - Setup
    
    init(wallet: WalletProtocol = WalletManager.shared.wallet,
         ethereumWallet: EthereumWalletBridgeAPI = WalletManager.shared.wallet.ethereum,
         dataRepository: BlockchainDataRepository = .shared,
         exchangeService: ExchangeService = .shared,
         paxAccountRepository: ERC20AssetAccountRepository<PaxToken> = PAXServiceProvider.shared.services.assetAccountRepository,
         variantFetcher: FeatureVariantFetching = AppFeatureConfigurator.shared) {
        self.wallet = wallet
        self.dataRepository = dataRepository
        self.exchangeService = exchangeService
        // TODO: Move this into a difference service that aggregates this logic
        // for all assets and utilize it in other flows (dashboard, send, swap, activity).
        self.paxTransactionService = AnyERC20HistoricalTransactionService<PaxToken>(bridge: ethereumWallet)
        self.variantFetcher = variantFetcher
    }
}
