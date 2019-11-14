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
    
    var isWaitingForEmailValidation = false
    
    // MARK: - Services
    
    private let interactor: EmailAuthorizationInteractor
    private let alertPresenter: AlertViewPresenter
        
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(services: EmailAuthorizationInteractor.Services = .init(),
         alertPresenter: AlertViewPresenter = .shared) {
        interactor = EmailAuthorizationInteractor(services: services)
        self.alertPresenter = alertPresenter
    }
    
    func authorize(_ completion: @escaping () -> Void) {
        showAlert()
        interactor.authorize
            .subscribe(
                onCompleted: {
                    completion()
                },
                onError: { error in
                    print("BOO: \(error)")
                }
            )
            .disposed(by: disposeBag)
        
        // TODO: Daniel - waiting logic
        isWaitingForEmailValidation = true
        showAlert()
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
