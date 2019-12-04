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
import RxCocoa

public final class AssetPriceViewPresenter {
    
    typealias PresentationState = DashboardAsset.State.AssetPrice.Presentation
        
    // MARK: - Exposed Properties
    
    var state: Observable<PresentationState> {
        return stateRelay
            .observeOn(MainScheduler.instance)
    }
    
    var alignment: Driver<UIStackView.Alignment> {
        return alignmentRelay.asDriver()
    }
    
    // MARK: - Injected
    
    private let interactor: AssetPriceViewInteracting
    
    // MARK: - Private Accessors
    
    private let alignmentRelay = BehaviorRelay<UIStackView.Alignment>(value: .fill)
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(interactor: AssetPriceViewInteracting,
                alignment: UIStackView.Alignment = .fill,
                descriptors: DashboardAsset.Value.Presentation.AssetPrice.Descriptors) {
        self.interactor = interactor
        self.alignmentRelay.accept(alignment)
        
        /// Map interaction state into presnetation state
        /// and bind it to `stateRelay`
        interactor.state
            .map { .init(with: $0, descriptors: descriptors) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
