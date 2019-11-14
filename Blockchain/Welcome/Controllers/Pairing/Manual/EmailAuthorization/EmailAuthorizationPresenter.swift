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
    
    private let interactor: EmailAuthorizationInteractor
    private let alertPresenter: AlertViewPresenter
    private let authenticationCoordinator: AuthenticationCoordinator
        
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    // TODO: Remote coordinator when refactored
    init(authenticationCoordinator: AuthenticationCoordinator = .shared,
         services: EmailAuthorizationInteractor.Services = .init(),
         alertPresenter: AlertViewPresenter = .shared) {
        interactor = EmailAuthorizationInteractor(services: services)
        self.alertPresenter = alertPresenter
        self.authenticationCoordinator = authenticationCoordinator
    }
    
    func authorize(_ completion: @escaping () -> Void) {
        authenticationCoordinator.isWaitingForEmailValidation = true
        showAlert()
        interactor.authorize
            .do(onDispose: { [weak self] in
                self?.authenticationCoordinator.isWaitingForEmailValidation = false
            })
            .subscribe(onCompleted: {
                completion()
            })
            .disposed(by: disposeBag)
    }
    
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
