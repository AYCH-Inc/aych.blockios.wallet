//  SendFeeInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift

/// Responsible for providing the correct fees for the send flow
protocol SendFeeInteracting: class {
    
    /// Streams the calculation state for the fee
    var calculationState: Observable<SendCalculationState> { get }
}
