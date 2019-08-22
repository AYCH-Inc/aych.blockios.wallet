//
//  SendDestinationAccountInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

/// The interaction protocol for the destination accounto on the send screen
protocol SendDestinationAccountInteracting {
    
    /// The interacted asset
    var asset: AssetType { get }
    
    /// Streams boolean value on whether the source account is connected to the PIT and has a valid PIT address
    var hasPitAccount: Observable<Bool> { get }
    
    /// Select PIT address
    var pitSelectedRelay: PublishRelay<Bool> { get }
    
    /// The selected / inserted destination account state
    var accountState: Observable<SendDestinationAccountState> { get }
    
    /// Sets the destination address
    func set(address: String)
}
