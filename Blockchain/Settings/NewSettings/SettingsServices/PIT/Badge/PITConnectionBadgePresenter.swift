//
//  PITConnectionBadgePresenter.swift
//  Blockchain
//
//  Created by AlexM on 12/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

final class PITConnectionBadgePresenter: BadgeAssetPresenting {
    
    typealias PresentationState = BadgeAsset.State.BadgeItem.Presentation
    
    var state: Observable<PresentationState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let interactor: PITConnectionBadgeInteractor
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    init(provider: PITConnectionStatusProviding) {
        interactor = PITConnectionBadgeInteractor(provider: provider)
        interactor.state.map { .init(with: $0) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
