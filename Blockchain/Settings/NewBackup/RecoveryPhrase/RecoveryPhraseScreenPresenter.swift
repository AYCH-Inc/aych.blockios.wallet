//
//  RecoveryPhraseScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import PlatformUIKit

final class RecoveryPhraseScreenPresenter {
    
    // MARK: - Private Properties
    
    private let router: RecoveryPhraseRouterAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Public Properties
    
    let recoveryViewModel: RecoveryPhraseViewModel
    let nextViewModel: ButtonViewModel
    let title = LocalizationConstants.RecoveryPhraseScreen.title
    let subtitle: LabelContent
    let description: LabelContent
    
    // MARK: - Init
    
    init(router: RecoveryPhraseRouterAPI,
         mnemonicAPI: MnemonicAccessAPI) {
        self.router = router
        self.recoveryViewModel = RecoveryPhraseViewModel(mnemonicAPI: mnemonicAPI)
        self.nextViewModel = .primary(with: LocalizationConstants.RecoveryPhraseScreen.next)
        
        Observable.combineLatest(self.nextViewModel.tapRelay,
                                 mnemonicAPI.mnemonic.asObservable())
            .map { $0.1.components(separatedBy: " ") }
            .bind { router.verify(mnemonic: $0) }
            .disposed(by: disposeBag)
        
        subtitle = LabelContent(
            text: LocalizationConstants.RecoveryPhraseScreen.subtitle,
            font: .mainSemibold(20.0),
            color: .textFieldText
        )
        description = LabelContent(
            text: LocalizationConstants.RecoveryPhraseScreen.description,
            font: .mainMedium(14.0),
            color: .textFieldText
        )
    }
}
