//
//  TierLimitsLabelContentPresenter.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay

final class TierLimitsLabelContentPresenter: LabelContentPresenting {
    
    typealias PresentationState = LabelContentAsset.State.LabelItem.Presentation
    
    var state: Observable<PresentationState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let interactor: TierLimitsLabelContentInteractor
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    init(provider: TierLimitsProviding,
         descriptors: LabelContentAsset.Value.Presentation.LabelItem.Descriptors) {
        interactor = TierLimitsLabelContentInteractor(limitsProviding: provider)
        interactor.state.map { .init(with: $0, descriptors: descriptors) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)

    }
}
