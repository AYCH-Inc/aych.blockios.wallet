//
//  CryptoFeeService.swift
//  PlatformKit
//
//  Created by Jack on 27/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol CryptoFeeServiceAPI {
    associatedtype FeeType: TransactionFee & Decodable
    
    /// This pulls from a Blockchain.info endpoint that serves up
    /// current <Crypto> transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var fees: Single<FeeType> { get }
    var communicator: NetworkCommunicatorAPI { get }
}
