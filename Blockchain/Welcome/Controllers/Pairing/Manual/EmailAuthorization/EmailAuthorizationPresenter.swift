//
//  EmailAuthorizationPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 13/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class EmailAuthorizationPresenter {
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.Onboarding.ManualPairingScreen.EmailAuthorizationAlert
        
    // MARK: - Services
    
    private let emailAuthorizationService: EmailAuthorizationService
    private let alertPresenter: AlertViewPresenter
    private let authenticationCoordinator: AuthenticationCoordinator
            
    // MARK: - Setup
    
    /// TODO: Remove `authenticationCoordinator` dependency when refactored
    init(authenticationCoordinator: AuthenticationCoordinator = .shared,
         emailAuthorizationService: EmailAuthorizationService,
         alertPresenter: AlertViewPresenter = .shared) {
        self.emailAuthorizationService = emailAuthorizationService
        self.alertPresenter = alertPresenter
        self.authenticationCoordinator = authenticationCoordinator
    }
    
    // MARK: - API
    
    /// Starts email authorization. This method is designed to fail silently
    /// As the only option to fail here is `cancellation` by calling `cancel()`
    /// but clients of `EmailAuthorizationPresenter` may subscribe and utilize
    /// `onError(_ error: Error)` if they need to.
    func authorize() -> Completable {
        authenticationCoordinator.isWaitingForEmailValidation = true
        showAlert()
        return emailAuthorizationService.authorize
            .do(onDispose: { [weak self] in
                self?.authenticationCoordinator.isWaitingForEmailValidation = false
            })
    }
    
    /// Cancels polling and waiting for authorization
    func cancel() {
        emailAuthorizationService.cancel()
    }
    
    // MARK: - Accessors
    
    private func showAlert() {
        alertPresenter.standardNotify(
            message: LocalizedString.message,
            title: LocalizedString.title,
            actions: [
                UIAlertAction(title: LocalizationConstants.openMailApp, style: .default) { _ in
                    UIApplication.shared.openMailApplication()
                }
            ]
        )
    }
}
