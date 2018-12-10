//
//  KYCVerifyEmailPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

typealias Email = String

protocol KYCVerifyEmailView: class {
    func showLoadingView()

    func sendEmailVerificationSuccess()

    func showError(message: String)

    func hideLoadingView()
}

protocol KYCConfirmEmailView: KYCVerifyEmailView {
    func emailVerifiedSuccess()
}

class KYCVerifyEmailPresenter {

    private weak var view: KYCVerifyEmailView?
    private let interactor: KYCVerifyEmailInteractor
    private var disposable: Disposable?

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    init(view: KYCVerifyEmailView, interactor: KYCVerifyEmailInteractor = KYCVerifyEmailInteractor()) {
        self.view = view
        self.interactor = interactor
    }

    func sendVerificationEmail(to email: Email) {
        view?.showLoadingView()
        disposable = interactor.sendVerificationEmail(to: email)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.view?.hideLoadingView()
                strongSelf.view?.sendEmailVerificationSuccess()
            }, onError: { [weak self] error in
                Logger.shared.error("Failed to send verification email: \(error.localizedDescription)")
                guard let strongSelf = self else {
                    return
                }
                strongSelf.view?.hideLoadingView()
                strongSelf.view?.showError(message: LocalizationConstants.KYC.failedToSendVerificationEmail)
            })
    }
}
