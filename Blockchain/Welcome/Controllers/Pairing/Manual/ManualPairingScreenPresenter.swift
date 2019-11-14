//
//  ManualPairingScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 10/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay
import RxCocoa

/// The view model for wallet pairing screen
final class ManualPairingScreenPresenter {
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.Onboarding.ManualPairingScreen
    
    // MARK: - Properties
        
    let navBarStyle = Screen.Style.Bar.lightContent(ignoresStatusBar: false, background: .primary)
    let titleStyle = Screen.Style.TitleView.text(value: LocalizedString.title)
    let walletIdTextFieldViewModel: TextFieldViewModel
    let passwordTextFieldViewModel: TextFieldViewModel
    let buttonViewModel = ButtonViewModel.primary(with: LocalizedString.button,
                                                  cornerRadius: 8)
    
    /// The total state of the presentation
    var state: Driver<FormPresentationState> {
        return stateRelay.asDriver()
    }
    
    /// Relay to the next route
    let nextRouteRelay = PublishRelay<Void>()
    
    // MARK: - Injected
    
    private let interactor: ManualPairingInteractor
    private let alertPresenter: AlertViewPresenter
    private let emailAuthorizationPresenter: EmailAuthorizationPresenter
    private let loadingViewPresenter: LoadingViewPresenting
    
    // MARK: - Accessors
        
    private let stateReducer = FormPresentationStateReducer()
    private let stateRelay = BehaviorRelay<FormPresentationState>(value: .invalid(.emptyTextField))
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: ManualPairingInteractor = ManualPairingInteractor(),
         emailAuthorizationPresenter: EmailAuthorizationPresenter = EmailAuthorizationPresenter(),
         alertPresenter: AlertViewPresenter = .shared,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared) {
        self.alertPresenter = alertPresenter
        self.emailAuthorizationPresenter = emailAuthorizationPresenter
        self.loadingViewPresenter = loadingViewPresenter
        self.interactor = interactor
        walletIdTextFieldViewModel = TextFieldViewModel(
            with: .walletIdentifier,
            validator: TextValidationFactory.walletIdentifier
        )
        passwordTextFieldViewModel = TextFieldViewModel(
            with: .password,
            validator: TextValidationFactory.loginPassword
        )
        
        let latestStatesObservable = Observable
            .combineLatest(
                walletIdTextFieldViewModel.state,
                passwordTextFieldViewModel.state
            )
            
        let stateObservable = latestStatesObservable
            .map(weak: self) { (self, payload) -> FormPresentationState in
                return try self.stateReducer.reduce(states: [payload.0, payload.1])
            }
            /// Should never get to `catchErrorJustReturn`.
            .catchErrorJustReturn(.invalid(.invalidTextField))
            .share(replay: 1)
        
        /// Bind the state
        stateObservable
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        /// Controls button `isEnabled` property
        stateObservable
            .map { $0.isValid }
            .bind(to: buttonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        // Extract the latest valid values to the interaction layer
        latestStatesObservable
            .compactMap { (walletIdState, passwordState) -> ManualPairingInteractor.Content? in
                guard let walletId = walletIdState.value, let password = passwordState.value else { return nil }
                return .init(walletIdentifier: walletId, password: password)
            }
            .bind(to: interactor.contentStateRelay)
            .disposed(by: disposeBag)
            
        buttonViewModel.tapRelay
            .bind { [unowned self] in
                self.pair(using: .standard)
            }
            .disposed(by: disposeBag)
        
        // Bind 2FA if required
        interactor.twoFA
            .bind { [weak self] type in
                self?.display2FAAlert(with: type)
            }
            .disposed(by: disposeBag)
        
        /// Bind authentication action
        interactor.authenticationAction
            .bind { [weak self] action in
                guard let self = self else { return }
                switch action {
                case.verifyEmail:
                    self.displayEmailAuthorizationAlert()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func viewDidLoad() {
        walletIdTextFieldViewModel.focusRelay.accept(true)
    }
    
    func viewDidDisappear() {
        emailAuthorizationPresenter.cancel()
    }
    
    private func pair(using type: ManualPairingInteractor.AuthType) {
        do {
            try interactor.pair(using: type)
        } catch { // TODO: Handle additional errors
            alertPresenter.showNoInternetConnectionAlert()
            loadingViewPresenter.hide()
        }
    }
    
    private func display2FAAlert(with type: AuthenticationTwoFactorType) {
        var resend: (() -> Void)?
        if type == .sms {
            resend = interactor.resendSMS
        }
        alertPresenter.notify2FA(type: type, resendAction: resend) { [weak self] otp in
            self?.pair(using: .twoFA(otp))
        }
    }
    
    private func displayEmailAuthorizationAlert() {
        emailAuthorizationPresenter.authorize { [weak self] in
            self?.pair(using: .standard)
        }
    }
}
