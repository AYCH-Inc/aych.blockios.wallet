//
//  TrasferFeeCellPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxRelay
import RxCocoa

/// Presenter for the transaction fees on transfer screen
final class TrasferFeeCellPresenter {
    
    let feesRelay = BehaviorRelay<String>(value: "")
    
    var fees: Driver<String> {
        return feesRelay.asDriver()
    }
    
    // MARK: - Services
    
    private let interactor: FeesInteracting
    
    // MARK: - Setup
    
    init(interactor: FeesInteracting) {
        self.interactor = interactor
    }
}
