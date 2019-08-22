//
//  SendFeeInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

/// The interaction layer implementation for fee calculation during the send flow.
final class SendFeeInteractor: SendFeeInteracting {

    // MARK: - Exposed Properties
    
    /// Streams the calculation state for the fee
    var calculationState: Observable<SendCalculationState> {
        return calculationStateRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    private let calculationStateRelay = BehaviorRelay<SendCalculationState>(value: .calculating)
    private let disposeBag = DisposeBag()
    
    // MARK: - Services

    /// The fee service that provides the fee as per asset
    private let feeService: SendFeeServicing
    
    /// The exchange service that provides crypto-fiat exchange rate
    private let exchangeService: SendExchangeServicing
    
    // MARK: - Setup
    
    init(feeService: SendFeeServicing,
         exchangeService: SendExchangeServicing) {
        self.feeService = feeService
        self.exchangeService = exchangeService
        
        // Combine the latest fee and exchange rate and continuous stream status updates
        Observable
            .combineLatest(feeService.fee, exchangeService.fiatPrice)
            .map { (fee, rate) -> SendCalculationState in
                return .value(TransferredValue(crypto: fee, exchangeRate: rate))
            }
            .startWith(.calculating)
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
}
