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

public protocol StellarConfigurationAPI {
    var configuration: Single<StellarConfiguration> { get }
}

public protocol StellarWalletOptionsBridgeAPI: class {
    var stellarConfigurationDomain: Single<String?> { get }
}

final public class StellarConfigurationService: StellarConfigurationAPI {
    
    public var configuration: Single<StellarConfiguration> {
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
        return bridgeAPI.stellarConfigurationDomain
            .map { domain -> StellarConfiguration in
                guard let stellarHorizon = domain else {
                    return StellarConfiguration.Blockchain.production
                }
                return StellarConfiguration(horizonURL: stellarHorizon)
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
    
    private let bridgeAPI: StellarWalletOptionsBridgeAPI
    
    // MARK: Private Static Properties
    
    private static let refreshInterval: TimeInterval = 60.0 * 60.0 // 1h
    
    public static let shared: StellarConfigurationService = StellarConfigurationService(bridge: WalletService.shared)
    
    public init(bridge: StellarWalletOptionsBridgeAPI = WalletService.shared) {
        self.bridgeAPI = bridge
    }
}

extension WalletService: StellarWalletOptionsBridgeAPI {
    public var stellarConfigurationDomain: Single<String?> {
        return walletOptions.map { value -> String? in
            return value.domains?.stellarHorizon
        }
    }
}
