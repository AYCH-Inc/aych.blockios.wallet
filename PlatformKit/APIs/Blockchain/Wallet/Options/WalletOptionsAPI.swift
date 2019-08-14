//
//  WalletOptionsAPI.swift
//  PlatformKit
//
//  Created by AlexM on 8/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol MaintenanceServicing {
    var serverUnderMaintenanceMessage: Single<String?> { get }
}

public protocol WalletOptionsAPI: MaintenanceServicing {
    var walletOptions: Single<WalletOptions> { get }
}
