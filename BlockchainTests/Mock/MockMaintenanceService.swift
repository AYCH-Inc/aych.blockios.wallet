//
//  MockMaintenanceService.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

struct MockMaintenanceService: MaintenanceServicing {
    let message: String?
    var serverUnderMaintenanceMessage: Single<String?> {
        return Single.just(message)
    }
}
