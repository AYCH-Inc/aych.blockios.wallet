//
//  PITConnectionBadgeInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

final class PITConnectionBadgeInteractor: BadgeAssetInteracting {
    
    typealias InteractionState = BadgeAsset.State.BadgeItem.Interaction
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    init(provider: PITConnectionStatusProviding) {
        provider.hasLinkedPITAccount
            .map { $0 == true ? .connected : .connect }
            .map { .loaded(next: $0) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
