//
//  LaunchAnnouncementInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class LaunchAnnouncementInteractor {

    // MARK: - Exposed Properties
    
    /// Streams an `UpdateType` element
    var updateType: Single<LaunchAnnouncementType> {
        return walletOptionsAPI.walletOptions
            .observeOn(MainScheduler.instance)
            .map { options in
                if options.downForMaintenance {
                    return .maintenance(options)
                } else if UIDevice.current.isUnsafe() {
                    return .jailbrokenWarning
                } else {
                    return .updateIfNeeded(options.updateType)
                }
            }
    }
    
    private let walletOptionsAPI: WalletOptionsAPI
    
    // MARK: - Setup
    
    init(walletOptionsAPI: WalletOptionsAPI = WalletService.shared) {
        self.walletOptionsAPI = walletOptionsAPI
    }
}
