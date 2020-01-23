//
//  RecoveryPhraseViewModel.swift
//  Blockchain
//
//  Created by AlexM on 1/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift

class RecoveryPhraseViewModel {
    
    // MARK: - Private Properties
    
    private let mnemonicAPI: MnemonicAccessAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Public Properties
    
    var words: Observable<[LabelContent]> {
        return mnemonicAPI.mnemonic.asObservable().map {
            let mnemonic = $0.components(separatedBy: " ")
            return mnemonic.map {
                LabelContent(
                    text: $0,
                    font: .mainSemibold(16.0),
                    color: .textFieldText,
                    accessibility: .none
                )
            }
        }
    }
    
    let copyButtonViewModel: ButtonViewModel
    
    // MARK: - Init
    
    init(mnemonicAPI: MnemonicAccessAPI,
         pasteboarding: Pasteboarding = UIPasteboard.general) {
        self.mnemonicAPI = mnemonicAPI
        self.copyButtonViewModel = .secondary(with: LocalizationConstants.RecoveryPhraseScreen.copyToClipboard)
        Observable.zip(self.copyButtonViewModel.tapRelay, mnemonicAPI.mnemonic.asObservable())
            .bind { [weak self] (_, mnemonic) in
                guard let self = self else { return }
                
                pasteboarding.string = mnemonic
                
                let theme = ButtonViewModel.Theme(
                    backgroundColor: .primaryButton,
                    contentColor: .white,
                    text: LocalizationConstants.Address.copiedButton
                )
                
                self.copyButtonViewModel.animate(theme: theme)
                
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
            }
            .disposed(by: disposeBag)
    }
}
