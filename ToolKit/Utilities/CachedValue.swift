//
//  CachedValue.swift
//  PlatformKit
//
//  Created by Jack on 19/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

/// This implements an in-memory cache with transparent refreshing/invalidation
/// after `refreshInterval` has elapsed.
public class CachedValue<Value> {
    
    public enum CacheError: Error {
        case fetchFailed
    }
    
    // MARK: - Properties
    
    public var value: Single<Value> {
        return Single.deferred {
            guard let cachedValue = self.cachedValue.value, !self.shouldRefresh else {
                return self.fetchValue
            }
            return Single.just(cachedValue)
        }
    }
    
    public var fetchValue: Single<Value> {
        guard let fetch = fetch else {
            return Single.error(CacheError.fetchFailed)
        }
        return fetch()
            .do(onSuccess: { [weak self] value in
                self?.cachedValue.accept(value)
                self?.lastRefreshRelay.accept(Date())
            })
    }
    
    // MARK: - Private properties
    
    private var shouldRefresh: Bool {
        let lastRefreshInterval = Date(timeIntervalSinceNow: -refreshInterval)
        return lastRefreshRelay.value.compare(lastRefreshInterval) == .orderedAscending
    }
    
    private var fetch: (() -> Single<Value>)?
    
    private let lastRefreshRelay: BehaviorRelay<Date>
    private let refreshInterval: TimeInterval
    private let cachedValue = BehaviorRelay<Value?>(value: nil)
    
    // MARK: - Init
    
    public init(refreshInterval: TimeInterval = 60.0) {
        self.refreshInterval = refreshInterval
        self.lastRefreshRelay = BehaviorRelay(value: Date(timeIntervalSinceNow: -refreshInterval))
    }
    
    // MARK: - Public methods
    
    public func setFetch(_ fetch: @escaping () -> Single<Value>) {
        self.fetch = fetch
    }
}
