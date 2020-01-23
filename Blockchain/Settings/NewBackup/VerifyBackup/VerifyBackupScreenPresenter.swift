//
//  VerifyBackupScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxCocoa

final class VerifyBackupScreenPresenter {
    
    // MARK: - Public Properties
    
    let verifyButtonViewModel: ButtonViewModel
    
    let firstTextFieldViewModel: ValidationTextFieldViewModel
    let secondTextFieldViewModel: ValidationTextFieldViewModel
    let thirdTextFieldViewModel: ValidationTextFieldViewModel
    
    let descriptionLabel: LabelContent
    let firstNumberLabel: LabelContent
    let secondNumberLabel: LabelContent
    let thirdNumberLabel: LabelContent
    let errorLabel: LabelContent
    
    // MARK: - Rx
    
    var errorDescriptionVisibility: Driver<Visibility> {
        return errorDescriptionVisibilityRelay.asDriver()
    }
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private let errorDescriptionVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    
    // MARK: - Init
    
    init(mnemonic: [String], router: VerifyBackupRouterAPI) {
        let subset = mnemonic.pick(3)
        
        let firstIndex = mnemonic.firstIndex(of: subset[0]) ?? 0
        let secondIndex = mnemonic.firstIndex(of: subset[1]) ?? 0
        let thirdIndex = mnemonic.firstIndex(of: subset[2]) ?? 0
        
        firstNumberLabel = LabelContent(text: "\(firstIndex + 1)", font: .mainMedium(12.0), color: .textFieldText)
        secondNumberLabel = LabelContent(text: "\(secondIndex + 1)", font: .mainMedium(12.0), color: .textFieldText)
        thirdNumberLabel = LabelContent(text: "\(thirdIndex + 1)", font: .mainMedium(12.0), color: .textFieldText)
        
        errorLabel = LabelContent(
            text: LocalizationConstants.VerifyBackupScreen.errorDescription,
            font: .mainMedium(12.0),
            color: .destructive
        )
        
        descriptionLabel = LabelContent(
            text: LocalizationConstants.VerifyBackupScreen.description,
            font: .mainMedium(14.0),
            color: .textFieldText
        )
        
        firstTextFieldViewModel = ValidationTextFieldViewModel(
            with: .backupVerfication(index: firstIndex),
            validator: TextValidationFactory.word(value: subset[0])
        )
        
        secondTextFieldViewModel = ValidationTextFieldViewModel(
            with: .backupVerfication(index: secondIndex),
            validator: TextValidationFactory.word(value: subset[1])
        )
        
        thirdTextFieldViewModel = ValidationTextFieldViewModel(
            with: .backupVerfication(index: thirdIndex),
            validator: TextValidationFactory.word(value: subset[2])
        )
        
        verifyButtonViewModel = .primary(with: LocalizationConstants.VerifyBackupScreen.action)
        
        let isValidObservable = Observable.combineLatest(
            firstTextFieldViewModel.state,
            secondTextFieldViewModel.state,
            thirdTextFieldViewModel.state
            ).map { $0.0.isValid && $0.1.isValid && $0.2.isValid }
            
        isValidObservable
            .bind(to: verifyButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        // TODO: Handle the empty state. e.g. If all the fields are
        // empty, we shouldn't show the error label.
        isValidObservable
            .map { $0 == true ? .hidden : .visible }
            .bind(to: errorDescriptionVisibilityRelay)
            .disposed(by: disposeBag)
        
        verifyButtonViewModel
            .tapRelay
            .bind { _ in
                router.verificationCompleted()
            }
            .disposed(by: disposeBag)
    }
}
