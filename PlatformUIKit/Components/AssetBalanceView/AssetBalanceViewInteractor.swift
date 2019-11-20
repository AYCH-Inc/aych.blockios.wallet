//
//  AssetBalanceViewInteractor.swift
//  Blockchain
//
//  Created by AlexM on 10/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

public final class AssetBalanceViewInteractor: AssetBalanceViewInteracting {
    
    public typealias InteractionState = DashboardAsset.State.AssetBalance.Interaction
    
    // MARK: - Exposed Properties
    
    public var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
            
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(assetBalanceFetching: AssetBalanceFetching) {
        assetBalanceFetching.calculationState
            .map { state -> InteractionState in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    return .loaded(
                        next: .init(
                            fiatValue: result.fiat,
                            cryptoValue: result.crypto
                        )
                    )
                }
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
