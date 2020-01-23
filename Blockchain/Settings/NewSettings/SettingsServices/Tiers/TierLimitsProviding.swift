//
//  TierLimitsProviding.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import PlatformKit

protocol TierLimitsProviding {
    var tiers: Observable<KYCUserTiersResponse> { get }
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

final class TierLimitsProvider: TierLimitsProviding {
    
    let fetchTriggerRelay = PublishRelay<Void>()
    
    private let repository: BlockchainDataRepository
    
    var tiers: Observable<KYCUserTiersResponse> {
        return Observable.combineLatest(repository.tiers, fetchTriggerRelay).map { $0.0 }
    }
    
    init(repository: BlockchainDataRepository = BlockchainDataRepository.shared) {
        self.repository = repository
    }
}
