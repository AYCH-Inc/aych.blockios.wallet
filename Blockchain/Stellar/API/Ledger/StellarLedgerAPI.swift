//
//  StellarLedgerAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol StellarLedgerAPI {
    var fallbackBaseReserve: Decimal { get }
    var fallbackBaseFee: Decimal { get }
    
    var current: Observable<StellarLedger> { get }
    var currentLedger: StellarLedger? { get }
}
