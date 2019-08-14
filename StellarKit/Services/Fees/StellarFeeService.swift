//
//  StellarFeeService.swift
//  StellarKit
//
//  Created by AlexM on 8/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public class StellarFeeService: StellarFeeServiceAPI {
    public static let shared: StellarFeeService = StellarFeeService()
    
    // MARK: Public Properties
    
    public var fees: Single<StellarTransactionFee> {
        return cryptoFeeService.fees
    }
    
    private let cryptoFeeService: CryptoFeeService<StellarTransactionFee>
    
    public init(cryptoFeeService: CryptoFeeService<StellarTransactionFee> = CryptoFeeService<StellarTransactionFee>.shared) {
        self.cryptoFeeService = cryptoFeeService
    }
}

public extension CryptoFeeService where T == StellarTransactionFee {
    static let shared: CryptoFeeService<T> = CryptoFeeService<T>()
}
