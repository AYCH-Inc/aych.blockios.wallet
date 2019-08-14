//
//  AnnouncementInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// The announcement interactor cross all the preliminary data
/// that is required to display announcements to the user
final class AnnouncementInteractor: AnnouncementInteracting {
    
    // MARK: - Services
    
    private let wallet: WalletProtocol
    private let dataRepository: BlockchainDataRepository
    private let exchangeService: ExchangeService
    
    /// Returns announcement preliminary data, according to which the relevant
    /// announcement will be displayed
    var preliminaryData: Single<AnnouncementPreliminaryData> {
        guard wallet.isInitialized() else {
            return Single.error(AnnouncementError.uninitializedWallet)
        }
        return Observable
            .zip(dataRepository.nabuUser,
                 dataRepository.tiers,
                 exchangeService.hasExecutedTrades().asObservable())
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .map { (user, tiers, hasTrades) -> AnnouncementPreliminaryData in
                return AnnouncementPreliminaryData(user: user,
                                                   tiers: tiers,
                                                   hasTrades: hasTrades)
            }
            .asSingle()
    }
    
    // MARK: - Setup
    
    init(wallet: WalletProtocol = WalletManager.shared.wallet,
         dataRepository: BlockchainDataRepository = .shared,
         exchangeService: ExchangeService = .shared) {
        self.wallet = wallet
        self.dataRepository = dataRepository
        self.exchangeService = exchangeService
    }
}
