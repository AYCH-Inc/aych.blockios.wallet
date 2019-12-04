//
//  AssetBalanceViewPresenter.swift
//  Blockchain
//
//  Created by AlexM on 10/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import RxCocoa
import RxRelay

public final class AssetBalanceViewPresenter {
    
    typealias PresentationState = DashboardAsset.State.AssetBalance.Presentation
        
    // MARK: - Exposed Properties
    
    var state: Observable<PresentationState> {
        return stateRelay
            .observeOn(MainScheduler.instance)
    }
    
    var alignment: Driver<UIStackView.Alignment> {
        return alignmentRelay.asDriver()
    }
    
    // MARK: - Injected
    
    private let interactor: AssetBalanceViewInteracting
    
    // MARK: - Private Accessors
    
    private let alignmentRelay = BehaviorRelay<UIStackView.Alignment>(value: .fill)
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(alignment: UIStackView.Alignment = .fill,
                interactor: AssetBalanceViewInteracting) {
        self.interactor = interactor
        self.alignmentRelay.accept(alignment)
        
        /// Map interaction state into presnetation state
        /// and bind it to `stateRelay`
        interactor.state
            .map {
                .init(with: $0)
        }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
