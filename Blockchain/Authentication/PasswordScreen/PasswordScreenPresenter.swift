//
//  PasswordScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxRelay

final class PasswordScreenPresenter {
    
    // MARK: - Types
    
    /// Confirmation route method
    typealias ConfirmHandler = (String) -> Void
    
    /// Dismissal route method
    typealias DismissHandler = () -> Void
    
    // MARK: - Exposed Properties
    
    let navBarStyle = Screen.Style.Bar.lightContent(
        ignoresStatusBar: false,
        background: .primary
    )
    let titleStyle: Screen.Style.TitleView
    let description: String
    let textFieldViewModel = TextFieldViewModel(
        with: .password,
        validator: TextValidationFactory.loginPassword
    )
    let buttonViewModel = ButtonViewModel.primary(
        with: LocalizationConstants.continueString,
        cornerRadius: 8
    )
    
    // MARK: - Injected
    
    // TODO: Remove dependency
    private let authenticationCoordinator: AuthenticationCoordinator
    private let interactor: PasswordScreenInteracting
    private let alertPresenter: AlertViewPresenter
    private let confirmHandler: ConfirmHandler
    private let dismissHandler: DismissHandler
    
    // MARK: - Private Accessors
    
    private let stateReducer = FormPresentationStateReducer()
    private let stateRelay = BehaviorRelay<FormPresentationState>(value: .invalid(.emptyTextField))
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(authenticationCoordinator: AuthenticationCoordinator = .shared,
         alertPresenter: AlertViewPresenter = .shared,
         interactor: PasswordScreenInteracting,
         confirmHandler: @escaping ConfirmHandler,
         dismissHandler: @escaping DismissHandler) {
        self.authenticationCoordinator = authenticationCoordinator
        self.alertPresenter = alertPresenter
        self.interactor = interactor
        self.confirmHandler = confirmHandler
        self.dismissHandler = dismissHandler
        
        let title: String
        switch interactor.type {
        case .importPrivateKey:
            title = LocalizationConstants.Authentication.ImportKeyPasswordScreen.title
            description = LocalizationConstants.Authentication.ImportKeyPasswordScreen.description
        case .actionRequiresPassword:
            title = LocalizationConstants.Authentication.DefaultPasswordScreen.title
            description = LocalizationConstants.Authentication.DefaultPasswordScreen.description
        case .etherService:
            title = LocalizationConstants.Authentication.EtherPasswordScreen.title
            description = LocalizationConstants.Authentication.EtherPasswordScreen.description
        }
        
        titleStyle = Screen.Style.TitleView.text(value: title)
        
        let stateObservable = textFieldViewModel.state
            .map(weak: self) { (self, payload) -> FormPresentationState in
                return try self.stateReducer.reduce(states: [payload])
            }
            /// Should never get to `catchErrorJustReturn`.
            .catchErrorJustReturn(.invalid(.invalidTextField))
            .share(replay: 1)
            
        stateObservable
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        stateObservable
            .map { $0.isValid }
            .bind(to: buttonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        textFieldViewModel.state
            .compactMap { $0.value }
            .bind(to: interactor.passwordRelay)
            .disposed(by: disposeBag)
        
        buttonViewModel.tapRelay
            .bind { [unowned self] in
                if self.interactor.isValid {
                    confirmHandler(interactor.passwordRelay.value)
                } else {
                    self.alertPresenter.standardError(
                        message: LocalizationConstants.Authentication.secondPasswordIncorrect
                    )
                }
            }
            .disposed(by: disposeBag)
    }
    
    func navigationBarLeadingButtonPressed() {
        dismissHandler()
    }
    
    func viewDidDisappear() {
        authenticationCoordinator.isShowingSecondPasswordScreen = false
    }
    
    func viewWillAppear() {
        authenticationCoordinator.isShowingSecondPasswordScreen = true
    }
}
