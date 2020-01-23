//
//  EmailSwitchViewInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import NetworkKit
import PlatformKit
import PlatformUIKit

class EmailSwitchViewInteractor: SwitchViewInteracting {
    
    typealias InteractionState = LoadingState<SwitchInteractionAsset>
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    var switchTriggerRelay = PublishRelay<Bool>()
    
    private let service: EmailNotificationSettingsServiceAPI & SettingsServiceAPI
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()

    init(service: EmailNotificationSettingsServiceAPI & SettingsServiceAPI) {
        self.service = service
        
        service.state
            .map { .init(with: $0) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        switchTriggerRelay
            .do(onNext: { _ in
                self.stateRelay.accept(.loading)
            })
            .flatMap(weak: self) { (self, result) -> Observable<Void> in
                self.service.emailNotifications(enabled: result)
                    .andThen(Observable.just(()))
            }
            .mapToVoid()
            .bind(to: service.fetchTriggerRelay)
            .disposed(by: disposeBag)
    }
}

fileprivate extension LoadingState where Content == (SwitchInteractionAsset) {
    
    /// Initializer that receives the interaction state and
    /// maps it to `self`
    init(with state: ValueCalculationState<WalletSettings>) {
        switch state {
        case .calculating,
             .invalid:
            self = .loading
        case .value(let value):
            let emailVerified = value.isEmailVerified
            let emailNotifications = value.isEmailNotificationsEnabled
            self = .loaded(next: .init(isOn: emailNotifications, isEnabled: emailVerified))
        }
    }
}
