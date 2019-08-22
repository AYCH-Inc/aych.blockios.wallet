//
//  SendFeeCellPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

/// The presnetation layer for the fee cell in the send screen
final class SendFeeCellPresenter {
    
    // MARK: - Expose Properties
    
    /// The visual reprentation for the fee
    /// Streams on the main thread and replay the latest value
    var fee: Driver<String> {
        return feeRelay.asDriver()
    }
    
    // MARK: - Private Properties
    
    private let feeRelay = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()

    // MARK: - Services
    
    private let interactor: SendFeeInteracting
    
    // MARK: - Setup
    
    init(interactor: SendFeeInteracting) {
        self.interactor = interactor
        
        // Extract the fee from the interactor and bind it to the relay
        interactor.calculationState
            .compactMap { $0.value }
            .map { $0.readableFormat }
            .bind(to: feeRelay)
            .disposed(by: disposeBag)
    }
}
