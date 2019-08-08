//
//  StellarConfigurationService.swift
//  Blockchain
//
//  Created by Jack on 21/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PlatformKit
import StellarKit

protocol StellarConfigurationAPI {
    var configuration: Single<StellarConfiguration> { get }
}

final class StellarConfigurationService: StellarConfigurationAPI {
    
    static let shared = StellarConfigurationService()
    
    var configuration: Single<StellarConfiguration> {
        return Single.deferred { [unowned self] in
            guard let cachedValue = self.cachedConfiguration.value, !self.shouldRefresh else {
                return self.fetchConfiguration
            }
            return Single.just(cachedValue)
        }
    }
    
    // MARK: Private Properties
    
    private var cachedConfiguration = BehaviorRelay<StellarConfiguration?>(value: nil)
    
    private var fetchConfiguration: Single<StellarConfiguration> {
        return walletService.walletOptions
            .map { walletOptions -> StellarConfiguration in
                guard
                    let stellarHorizon = walletOptions.domains?.stellarHorizon
                else {
                    return StellarConfiguration.Blockchain.production
                }
                return StellarConfiguration(
                    horizonURL: stellarHorizon
                )
            }
            .do(onSuccess: { [weak self] _ in
                self?.lastRefresh = Date()
            })
            .catchErrorJustReturn(StellarConfiguration.Blockchain.production)
            .do(onSuccess: { [weak self] configuration in
                self?.cachedConfiguration.accept(configuration)
            })
    }
    
    private var shouldRefresh: Bool {
        let lastRefreshInterval = Date(timeIntervalSinceNow: -StellarConfigurationService.refreshInterval)
        return lastRefresh.compare(lastRefreshInterval) == .orderedAscending
    }
    
    private var lastRefresh: Date = Date(timeIntervalSinceNow: -StellarConfigurationService.refreshInterval)
    
    private let walletService: WalletService
    
    // MARK: Private Static Properties
    
    private static let refreshInterval: TimeInterval = 60.0 * 60.0 // 1h
    
    init(walletService: WalletService = WalletService.shared) {
        self.walletService = walletService
    }
}
