//
//  SendInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

/// This protocol provides the inner components of a send
protocol SendInteracting {
    
    /// The asset type to derive outputs from
    var asset: AssetType { get }
    
    /// The interactor for the source acccount
    var sourceInteractor: SendSourceAccountInteracting { get }
    
    /// The interactor for the destination account
    var destinationInteractor: SendDestinationAccountInteracting { get }
    
    /// The interactor for the sent amount
    var amountInteractor: SendAmountInteracting { get }
    
    /// The interactor for the spendable balance
    var spendableBalanceInteractor: SendSpendableBalanceInteracting { get }
    
    /// The interactor for the fees account
    var feeInteractor: SendFeeInteracting { get }
    
    /// The state of the input
    var inputState: Observable<SendInputState> { get }
    
    /// Sets an address. Handy in injecting values from an external source of information
    func set(address: String)
    
    /// Sets a crypto amount. Handy in injecting values from an external source of information
    func set(cryptoAmount: String)
    
    /// Cleans the state of things
    func clean()
    
    /// Executes the transaction
    func send() -> Single<Void>
        
    /// Prepare for sending - must be called BEFORE `send()`
    func prepareForSending() -> Single<Void>
}
