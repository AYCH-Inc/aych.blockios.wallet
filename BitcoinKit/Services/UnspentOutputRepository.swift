//
//  UnspentOutputRepository.swift
//  BitcoinKit
//
//  Created by Jack on 08/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

protocol UnspentOutputRepositoryAPI {
    var unspentOutputs: Single<UnspentOutputs> { get }
    var fetchUnspentOutputs: Single<UnspentOutputs> { get }
}

final class UnspentOutputRepository: UnspentOutputRepositoryAPI {
    
    public typealias Bridge = BitcoinWalletBridgeAPI
    
    // MARK: - Public properties
    
    public var unspentOutputs: Single<UnspentOutputs> {
        cachedUnspentOutputs.value
    }
    
    public var fetchUnspentOutputs: Single<UnspentOutputs> {
        cachedUnspentOutputs.fetchValue
    }
    
    // MARK: - Private properties
    
    private let bridge: Bridge
    private let client: APIClientAPI
    private let cachedUnspentOutputs: CachedValue<UnspentOutputs>
    
    // MARK: - Init
    
    init(with bridge: Bridge, client: APIClientAPI = APIClient()) {
        self.bridge = bridge
        self.client = client
        
        self.cachedUnspentOutputs = CachedValue<UnspentOutputs>(
            refreshInterval: 10
        )
        
        cachedUnspentOutputs.setFetch { [weak self] in
            guard let self = self else {
                return Single.error(PlatformKitError.nullReference(Self.self))
            }
            return self.fetchAllUnspentOutputs()
        }
    }
    
    // MARK: - Private methods
    
    private func fetchAllUnspentOutputs() -> Single<UnspentOutputs> {
        return bridge.wallets
            .map { wallets -> [String] in
                wallets.map { $0.publicKey }
            }
            .flatMap(weak: self) { (self, addresses) -> Single<UnspentOutputs> in
                self.fetchUnspentOutputs(for: addresses)
            }
    }
    
    private func fetchUnspentOutputs(for addresses: [String]) -> Single<UnspentOutputs> {
        return client.unspentOutputs(addresses: addresses)
            .map { UnspentOutputs(networkResponse: $0) }
    }
}

