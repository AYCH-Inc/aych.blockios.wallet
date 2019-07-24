//
//  VerifyEmailPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

typealias EmailAddress = String

protocol EmailConfirmationInterface: EmailVerificationInterface {
    func emailVerifiedSuccess()
}

class VerifyEmailPresenter {

    private weak var view: EmailVerificationInterface?
    private let interactor: EmailVerificationService
    private let disposables = CompositeDisposable()

    deinit {
        disposables.dispose()
    }

    init(view: EmailVerificationInterface, interactor: EmailVerificationService = EmailVerificationService()) {
        self.view = view
        self.interactor = interactor
    }

    func waitForEmailConfirmation() -> Disposable {
        return interactor.waitForEmailVerification()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEmailVerified in
                guard let strongSelf = self else {
                    return
                }
                guard isEmailVerified else {
                    Logger.shared.debug("Email not verified")
                    return
                }
                guard let confirmView = strongSelf.view as? EmailConfirmationInterface else {
                    return
                }
                confirmView.emailVerifiedSuccess()
            })
    }
    
    var userEmail: Single<Email> {
        return interactor.userEmail
    }

    func sendVerificationEmail(to email: EmailAddress, contextParameter: ContextParameter? = nil) {
        view?.updateLoadingViewVisibility(.visible)
        let disposable = interactor.sendVerificationEmail(to: email, contextParameter: contextParameter)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .do(onDispose: { [weak self] in
                self?.view?.updateLoadingViewVisibility(.hidden)
            })
            .subscribe(onCompleted: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.view?.sendEmailVerificationSuccess()
            }, onError: { [weak self] error in
                Logger.shared.error("Failed to send verification email: \(error.localizedDescription)")
                guard let strongSelf = self else {
                    return
                }
                strongSelf.view?.showError(message: LocalizationConstants.KYC.failedToSendVerificationEmail)
            })
        disposables.insertWithDiscardableResult(disposable)
    }
}
