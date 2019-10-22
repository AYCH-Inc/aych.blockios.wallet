//
//  PasswordRequiredScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 10/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay
import RxCocoa

final class PasswordRequiredScreenPresenter {
    
    /// Typealias to lessen verbosity
    private typealias LocalizedString = LocalizationConstants.Onboarding.PasswordRequiredScreen
        
    // MARK: - Exposed Properties
    
    let navBarStyle = Screen.Style.Bar.lightContent(ignoresStatusBar: false, background: .primary)
    let titleStyle = Screen.Style.TitleView.text(value: LocalizedString.title)
    let description = LocalizedString.description
    let forgetDescription = LocalizedString.forgetWalletDescription
    let passwordTextFieldViewModel = TextFieldViewModel(
        with: .password,
        validator: TextValidationFactory.loginPassword
    )
    let continueButtonViewModel = ButtonViewModel.primary(
        with: LocalizedString.continueButton,
        cornerRadius: 8
    )
    let forgotPasswordButtonViewModel = ButtonViewModel.secondary(
        with: LocalizedString.forgotButton,
        cornerRadius: 8
    )
    
    let forgetWalletButtonViewModel = ButtonViewModel.destructive(
        with: LocalizedString.forgetWalletButton,
        cornerRadius: 8
    )
    
    /// The total state of the presentation
    var state: Driver<FormPresentationState> {
        return stateRelay.asDriver()
    }
    
    // MARK: - Injected
    
    private let launchAnnouncementPresenter: LaunchAnnouncementPresenter
    private let interactor: PasswordRequiredScreenInteractor
    private let alertPresenter: AlertViewPresenter
    private unowned let onboardingRouter: OnboardingRouter
    
    // MARK: - Private Properties
    
    private let stateReducer = FormPresentationStateReducer()
    private let stateRelay = BehaviorRelay<FormPresentationState>(value: .invalid(.emptyTextField))
            
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(onboardingRouter: OnboardingRouter = AppCoordinator.shared.onboardingRouter,
         launchAnnouncementPresenter: LaunchAnnouncementPresenter = LaunchAnnouncementPresenter(),
         interactor: PasswordRequiredScreenInteractor = PasswordRequiredScreenInteractor(),
         alertPresenter: AlertViewPresenter = .shared) {
        self.onboardingRouter = onboardingRouter
        self.launchAnnouncementPresenter = launchAnnouncementPresenter
        self.alertPresenter = alertPresenter
        self.interactor = interactor
                    
        let stateObservable = passwordTextFieldViewModel.state
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
            .bind(to: continueButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        passwordTextFieldViewModel.state
            .compactMap { $0.value }
            .bind(to: interactor.passwordRelay)
            .disposed(by: disposeBag)
        
        forgetWalletButtonViewModel.tapRelay
            .bind { [unowned self] in
                self.showForgetWalletAlert()
            }
            .disposed(by: disposeBag)
        
        forgotPasswordButtonViewModel.tapRelay
            .bind { [unowned self] in
                self.showSupportAlert()
            }
            .disposed(by: disposeBag)
        
        continueButtonViewModel.tapRelay
            .bind { [weak self] in
                self?.authenticate()
            }
            .disposed(by: disposeBag)
        
        interactor.error
            .bind { [weak self] error in
                self?.handle(error: error)
            }
            .disposed(by: disposeBag)
    }
    
    /// Should be invoked as the presenting view appears
    func viewWillAppear() {
        launchAnnouncementPresenter.execute()
    }
    
    /// Handles any interaction error
    private func handle(error: PasswordRequiredScreenInteractor.ErrorType) {
        /// TODO: Refactor when the interaction layer and `AuthenticationCoordinator` are refactored.
        switch error {
        case .keychain:
            alertPresenter.showKeychainReadError()
        }
    }
    
    private func showForgetWalletAlert() {
        let title = LocalizedString.ForgetWalletAlert.title
        let message = LocalizedString.ForgetWalletAlert.message
        let okAction = UIAlertAction(title: LocalizedString.ForgetWalletAlert.forgetButton, style: .destructive) { _ in
            self.forgetWallet()
        }
        let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        alertPresenter.standardNotify(
            message: message,
            title: title,
            actions: [okAction, cancelAction]
        )
    }
    
    private func showSupportAlert() {
        let title = LocalizedString.ForgotPasswordAlert.title
        let message = String(format: LocalizedString.ForgotPasswordAlert.message, Constants.Url.blockchainSupport)
        let okAction = UIAlertAction(title: LocalizationConstants.continueString, style: .default) { _ in
            guard let url = URL(string: Constants.Url.forgotPassword) else { return }
            UIApplication.shared.open(url)
        }
        let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        alertPresenter.standardNotify(
            message: message,
            title: title,
            actions: [okAction, cancelAction]
        )
    }
    
    /// Forgets the wallet and routes to the first onboarding screen
    private func forgetWallet() {
        interactor.forget()
        onboardingRouter.start()
    }
    
    /// Authenticate
    private func authenticate() {
        interactor.authenticate()
    }
}
