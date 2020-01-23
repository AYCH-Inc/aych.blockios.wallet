//
//  VerifyEmailPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import PlatformKit

protocol EmailConfirmationInterface: EmailVerificationInterface {
    func emailVerifiedSuccess()
}

final class VerifyEmailPresenter {

    var email: Single<String> {
        return emailSettingsService.email
            .observeOn(MainScheduler.instance)
    }
    
    // MARK: - Private Properties
    
    private weak var view: EmailVerificationInterface?
    private let emailVerificationService: EmailVerificationServiceAPI
    private let emailSettingsService: EmailSettingsServiceAPI
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(view: EmailVerificationInterface,
         emailVerificationService: EmailVerificationServiceAPI = UserInformationServiceProvider.default.emailVerification,
         emailSettingsService: EmailSettingsServiceAPI = UserInformationServiceProvider.default.settings) {
        self.view = view
        self.emailVerificationService = emailVerificationService
        self.emailSettingsService = emailSettingsService
    }

    func waitForEmailConfirmation() {
        emailVerificationService.verifyEmail()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onCompleted: { [weak view] in
                    guard let view = view as? EmailConfirmationInterface else {
                        return
                    }
                    view.emailVerifiedSuccess()
                }
            )
            .disposed(by: disposeBag)
    }
    
    func cancel() {
        emailVerificationService.cancel()
            .subscribe()
            .disposed(by: disposeBag)
    }

    func sendVerificationEmail(to email: String,
                               contextParameter: FlowContext? = nil) {
        emailSettingsService.update(email: email, context: contextParameter)
            .observeOn(MainScheduler.instance)
            .do(
                onSubscribed: { [weak view] in
                    view?.updateLoadingViewVisibility(.visible)
                },
                onDispose: { [weak view] in
                    view?.updateLoadingViewVisibility(.hidden)
                }
            )
            .subscribe(
                onCompleted: { [weak view] in
                    view?.sendEmailVerificationSuccess()
                },
                onError: { [weak view] error in
                    view?.showError(message: LocalizationConstants.KYC.failedToSendVerificationEmail)
                }
            )
            .disposed(by: disposeBag)
    }
}
