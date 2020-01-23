//
//  DefaultLabelContentPresenter.swift
//  Blockchain
//
//  Created by AlexM on 12/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay

final class DefaultLabelContentPresenter: LabelContentPresenting {
    
    typealias PresentationState = LabelContentAsset.State.LabelItem.Presentation
    typealias Descriptors = LabelContentAsset.Value.Presentation.LabelItem.Descriptors
    
    var state: Observable<PresentationState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let interactor: DefaultLabelContentInteractor
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    init(title: String,
         descriptors: Descriptors) {
        interactor = DefaultLabelContentInteractor(value: title)
        interactor.state.map { .init(with: $0, descriptors: descriptors) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)

    }
}
