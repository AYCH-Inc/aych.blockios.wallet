//
//  PITConnectionStatusProviding.swift
//  Blockchain
//
//  Created by AlexM on 12/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// `PITConnectionStatusProviding` is an API for determining if the user
/// has connected their wallet to the PIT
protocol PITConnectionStatusProviding {
    var hasLinkedPITAccount: Observable<Bool> { get }
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

final class PITConnectionStatusProvider: PITConnectionStatusProviding {
    
    // MARK: - PITConnectionStatusProviding
    
    let fetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private let blockchainRepository: BlockchainDataRepository
    
    init(blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared) {
        self.blockchainRepository = blockchainRepository
    }
    
    var hasLinkedPITAccount: Observable<Bool> {
        return Observable.combineLatest(
            blockchainRepository.fetchNabuUser().asObservable(),
            fetchTriggerRelay).flatMap {
                return Single.just($0.0.hasLinkedExchangeAccount)
        }
    }
}
