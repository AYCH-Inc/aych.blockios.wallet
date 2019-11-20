//
//  AssetPriceViewPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

public final class AssetPriceViewPresenter {
    
    typealias PresentationState = DashboardAsset.State.AssetPrice.Presentation
        
    // MARK: - Exposed Properties
    
    var state: Observable<PresentationState> {
        return stateRelay
            .observeOn(MainScheduler.instance)
    }
    
    // MARK: - Injected
    
    private let interactor: AssetPriceViewInteracting
    
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(interactor: AssetPriceViewInteracting,
                descriptors: DashboardAsset.Value.Presentation.AssetPrice.Descriptors) {
        self.interactor = interactor
        
        /// Map interaction state into presnetation state
        /// and bind it to `stateRelay`
        interactor.state
            .map { .init(with: $0, descriptors: descriptors) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
