//
//  TwoFactorVerificationBadgeInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

final class TwoFactorVerificationBadgeInteractor: BadgeAssetInteracting {
    
    typealias InteractionState = BadgeAsset.State.BadgeItem.Interaction
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(service: SettingsServiceAPI) {
        service.state
            .map { state -> InteractionState in
                switch state {
                case .value(let settings):
                    if settings.authenticator.isTwoFactor {
                        return .loaded(next: .verified)
                    } else {
                        return .loaded(next: .unverified)
                    }
                case .calculating, .invalid:
                    return .loading
                }
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
