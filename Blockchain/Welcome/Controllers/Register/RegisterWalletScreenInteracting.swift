//
//  RegisterWalletScreenInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// Content for wallet registration (creation / recovery)
struct WalletRegistrationContent {
    var email = ""
    var password = ""
}

protocol RegisterWalletScreenInteracting: class {
    
    /// Content relay
    var contentStateRelay: BehaviorRelay<WalletRegistrationContent> { get }
    
    /// Reflects errors received from the JS layer
    var error: Observable<String> { get }
    
    /// Executes the registration (creation / recovery)
    func execute() throws
}
