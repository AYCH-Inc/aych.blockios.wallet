//
//  ServerMaintenance.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol MaintenanceServicing {
    var serverUnderMaintenanceMessage: Single<String?> { get }
}

