//
//  SwipeReceiveSwitchViewPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit
import PlatformUIKit

class SwipeReceiveSwitchViewPresenter: SwitchViewPresenting {
    
    var viewModel: SwitchViewModel = .primary()
    
    private let interactor: SwitchViewInteracting
    private let disposeBag = DisposeBag()
    
    init(appSettings: BlockchainSettings.App) {
        interactor = SwipeReceiveSwitchViewInteractor(
            appSettings: appSettings
        )
        
        viewModel.isSwitchedOnRelay
            .bind(to: interactor.switchTriggerRelay)
            .disposed(by: disposeBag)
        
        interactor.state
            .compactMap { $0.value }
            .map { $0.isEnabled }
            .bind(to: viewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        interactor.state
            .compactMap { $0.value }
            .map { $0.isOn }
            .bind(to: viewModel.isOnRelay)
            .disposed(by: disposeBag)
    }
}

