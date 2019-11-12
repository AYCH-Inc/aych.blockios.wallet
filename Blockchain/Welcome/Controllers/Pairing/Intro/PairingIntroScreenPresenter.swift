//
//  PairingIntroScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 11/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxCocoa

/// A presenter for pairing intro screen
struct PairingIntroScreenPresenter {
        
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.Onboarding.PairingIntroScreen
    
    // MARK: - Properties
    
    let navBarStyle = Screen.Style.Bar.lightContent(ignoresStatusBar: false, background: .primary)
    let titleStyle = Screen.Style.TitleView.text(value: LocalizedString.title)
    let instructionViewModels: [InstructionCellViewModel] = {
        let inputs: [[InteractableTextViewModel.Input]] = [
            [.text(string: LocalizedString.Instruction.firstPrefix),
             .url(string: LocalizedString.Instruction.firstSuffix, url: Constants.Url.blockchainWalletLogin)
            ],
            [.text(string: LocalizedString.Instruction.second)],
            [.text(string: LocalizedString.Instruction.third)]
        ]
        return inputs.enumerated().map {
            InstructionCellViewModel(number: $0.offset + 1, inputs: $0.element)
        }
    }()
    let primaryButtonViewModel = ButtonViewModel.primary(
        with: LocalizedString.primaryButton,
        cornerRadius: 8
    )
    let secondaryButtonViewModel = ButtonViewModel.secondary(
        with: LocalizedString.secondaryButton,
        cornerRadius: 8
    )
    
    /// Should connect to manual pairing flow
    let manualPairingNavigationRelay = PublishRelay<Void>()
    
    /// Should connect to auto pairing flow
    let autoPairingNavigationRelay = PublishRelay<Void>()
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init() {
        primaryButtonViewModel.tapRelay
            .bind(to: autoPairingNavigationRelay)
            .disposed(by: disposeBag)
        secondaryButtonViewModel.tapRelay
            .bind(to: manualPairingNavigationRelay)
            .disposed(by: disposeBag)
    }
}

