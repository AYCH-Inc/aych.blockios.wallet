//
//  AddressInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol AddressInteracting {
    
    /// The associated asset
    var asset: AssetType { get }
    
    /// The current address
    var address: Single<WalletAddressContent> { get }
    
    /// Streams payments received to that address
    var receivedPayment: Observable<ReceivedPaymentDetails> { get }
}
