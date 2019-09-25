//
//  AnalyticsUserPropertyInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 01/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

/// This class connect the analytics service with the application layer
final class AnalyticsUserPropertyInteractor {
    
    // MARK: - Properties
    
    private let recorder: UserPropertyRecording
    private let wallet: Wallet
    private let exchangeService: ExchangeHistoryAPI
    private let dataRepository: BlockchainDataRepository
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(recorder: UserPropertyRecording = AnalyticsUserPropertyRecorder(),
         dataRepository: BlockchainDataRepository = .shared,
         exchangeService: ExchangeHistoryAPI = ExchangeService.shared,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.recorder = recorder
        self.dataRepository = dataRepository
        self.wallet = wallet
        self.exchangeService = exchangeService
    }
    
    /// Records all the user properties
    func record() {
        Single.zip(dataRepository.nabuUser.first(), dataRepository.tiers.first())
            .subscribe(
                onSuccess: { [weak self] (user, tiers) in
                    self?.record(user: user, tiers: tiers)
                },
                onError: { error in
                    Logger.shared.error(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func record(user: NabuUser?, tiers: KYCUserTiersResponse?) {
        if let identifier = user?.personalDetails?.identifier {
            recorder.record(id: identifier)
        }
        
        if let identifier = wallet.guid {
            let property = HashedUserProperty(key: .walletID, value: identifier)
            recorder.record(property)
        }
        
        if let tiers = tiers {
            let value = "\(tiers.latestTier.rawValue)"
            recorder.record(StandardUserProperty(key: .kycLevel, value: value))
        }
        
        if let date = user?.kycCreationDate {
            recorder.record(StandardUserProperty(key: .kycCreationDate, value: date))
        }
        
        if let date = user?.kycUpdateDate {
            recorder.record(StandardUserProperty(key: .kycUpdateDate, value: date))
        }
    }
}
