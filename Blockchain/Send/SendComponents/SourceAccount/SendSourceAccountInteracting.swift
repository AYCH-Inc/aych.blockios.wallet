//
//  SendSourceAccountInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// The interaction protocol for the source account on the send flow.
protocol SendSourceAccountInteracting {
    
    /// The source account to send crypto from
    var account: Observable<SendSourceAccount> { get }
}
