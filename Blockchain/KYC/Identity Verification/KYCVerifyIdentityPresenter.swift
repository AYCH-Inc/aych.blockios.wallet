//
//  KYCVerifyIdentityPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol KYCVerifyIdentityView: class {
    func showLoadingIndicator()

    func hideLoadingIndicator()

    func showDocumentTypes(_ types: [KYCDocumentType])

    func showErrorMessage(_ message: String)
    
    func showCameraPermissionsDenied()
    
    func promptToAcceptCameraPermissions()
    
    func sendToVeriff()
}

class KYCVerifyIdentityPresenter {
    private let interactor: KYCVerifyIdentityInteractor
    private weak var view: KYCVerifyIdentityView?
    private var disposable: Disposable?

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    init(interactor: KYCVerifyIdentityInteractor, view: KYCVerifyIdentityView) {
        self.interactor = interactor
        self.view = view
    }

    func presentDocumentTypeOptions(_ countryCode: String) {
        view?.showLoadingIndicator()
        disposable = interactor.supportedDocumentTypes(countryCode)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] documentTypes in
                self?.view?.hideLoadingIndicator()
                self?.view?.showDocumentTypes(documentTypes)
            }, onError: { [weak self] error in
                Logger.shared.error("Error: \(error.localizedDescription)")
                self?.view?.hideLoadingIndicator()
                self?.view?.showErrorMessage(LocalizationConstants.Errors.genericError)
            })
    }
    
    func didTapNext() {
        if PermissionsRequestor.shouldDisplayCameraPermissionsRequest() {
            view?.promptToAcceptCameraPermissions()
            return
        }
        if PermissionsRequestor.cameraRefused() == false {
            view?.sendToVeriff()
        } else {
            view?.showCameraPermissionsDenied()
        }
    }
    
    func requestedCameraPermissions() {
        permissionsRequestor.requestPermissions(camera: true) { [weak self] in
            guard let this = self else { return }
            switch PermissionsRequestor.cameraEnabled() {
            case true:
                this.view?.sendToVeriff()
            case false:
                this.view?.showCameraPermissionsDenied()
            }
        }
    }
    
    private lazy var permissionsRequestor: PermissionsRequestor = {
       return PermissionsRequestor()
    }()
}
