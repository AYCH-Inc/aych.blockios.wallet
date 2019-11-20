//
//  DashboardNoticeInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 05/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// Supports notices
final class DashboardNoticeInteractor {
        
    /// A `Single` that streams a boolean value indicating ifthe user has a lockbox linked
    var lockbox: Single<Bool> {
        return Single
            .just(lockboxRepository.hasLockbox)
            // Subscribe on the main queue because of the JS layer
            .subscribeOn(MainScheduler.instance)
    }
    
    // MARK: - Services
    
    private let lockboxRepository: LockboxRepositoryAPI
    
    // MARK: - Setup
    
    init(lockboxRepository: LockboxRepositoryAPI) {
        self.lockboxRepository = lockboxRepository
    }
}
