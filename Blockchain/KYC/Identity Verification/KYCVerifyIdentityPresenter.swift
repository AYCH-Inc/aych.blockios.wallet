//
//  KYCVerifyIdentityPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

protocol KYCVerifyIdentityView: class {
    func showCameraPermissionsDenied()

    func promptToAcceptCameraPermissions()

    func sendToVeriff()

    func showDocumentTypes(_ types: [KYCDocumentType])
}

protocol KYCVerifyIdentityDelegate: class {
    func submitVerification(
        onCompleted: @escaping (() -> Void),
        onError: @escaping ((Error) -> Void)
    )
    func createCredentials(
        onSuccess: @escaping ((VeriffCredentials) -> Void),
        onError: @escaping ((Error) -> Void)
    )
}

class KYCVerifyIdentityPresenter {
    private let interactor: KYCVerifyIdentityInteractor
    private weak var loadingView: LoadingView?

    // TODO: Separate and use in a different presenter specifically made
    // for the KYCVerifyIdentityViewController.
    weak var identityView: KYCVerifyIdentityView?

    private lazy var permissionsRequestor: PermissionsRequestor = {
        return PermissionsRequestor()
    }()

    init(
        interactor: KYCVerifyIdentityInteractor,
        loadingView: LoadingView
    ) {
        self.interactor = interactor
        self.loadingView = loadingView
    }

    func presentDocumentTypeOptions(_ countryCode: String) {
        loadingView?.showLoadingIndicator()
        interactor.supportedDocumentTypes(
            countryCode: countryCode,
            onSuccess: { [weak self] documentTypes in
                self?.loadingView?.hideLoadingIndicator()
                self?.identityView?.showDocumentTypes(documentTypes)
            },
            onError: { [weak self] error in
                Logger.shared.error("Error: \(error.localizedDescription)")
                self?.loadingView?.hideLoadingIndicator()
                self?.loadingView?.showErrorMessage(LocalizationConstants.Errors.genericError)
            }
        )
    }
}

extension KYCVerifyIdentityPresenter: KYCVerifyIdentityDelegate {
    func submitVerification(onCompleted: @escaping (() -> Void), onError: @escaping ((Error) -> Void)) {
        interactor.submitVerification(onCompleted: onCompleted, onError: onError)
    }

    func createCredentials(onSuccess: @escaping ((VeriffCredentials) -> Void), onError: @escaping ((Error) -> Void)) {
        interactor.createCredentials(onSuccess: onSuccess, onError: onError)
    }
    
    func didTapNext() {
        if PermissionsRequestor.shouldDisplayCameraPermissionsRequest() {
            identityView?.promptToAcceptCameraPermissions()
            return
        }
        if PermissionsRequestor.cameraRefused() == false {
            identityView?.sendToVeriff()
        } else {
            identityView?.showCameraPermissionsDenied()
        }
    }
    
    func requestedCameraPermissions() {
        permissionsRequestor.requestPermissions(camera: true) { [weak self] in
            guard let this = self else { return }
            switch PermissionsRequestor.cameraEnabled() {
            case true:
                this.identityView?.sendToVeriff()
            case false:
                this.identityView?.showCameraPermissionsDenied()
            }
        }
    }
}
