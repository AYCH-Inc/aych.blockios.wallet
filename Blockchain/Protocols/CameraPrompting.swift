//
//  CameraPrompting.swift
//  PlatformUIKit
//
//  Created by kevinwu on 1/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

// TODO: move this to PlatformUIKit with Localizations

protocol CameraPrompting: class {
    var permissionsRequestor: PermissionsRequestor { get set }
    var delegate: CameraPromptingDelegate? { get set }

    // Call this when an action requires camera usage
    func willUseCamera()

    func requestCameraPermissions()
}

extension CameraPrompting {
    func willUseCamera() {
        if PermissionsRequestor.shouldDisplayCameraPermissionsRequest() {
            delegate?.promptToAcceptCameraPermissions(confirmHandler: {
                self.requestCameraPermissions()
            })
            return
        }
        if PermissionsRequestor.cameraRefused() == false {
            delegate?.proceed()
        } else {
            delegate?.showCameraPermissionsDenied()
        }
    }

    func requestCameraPermissions() {
        permissionsRequestor.requestPermissions(camera: true) { [weak self] in
            guard let this = self else { return }
            switch PermissionsRequestor.cameraEnabled() {
            case true:
                this.delegate?.proceed()
            case false:
                this.delegate?.showCameraPermissionsDenied()
            }
        }
    }
}

protocol CameraPromptingDelegate: class {
    func proceed()
    func showCameraPermissionsDenied()
    func promptToAcceptCameraPermissions(confirmHandler: @escaping (() -> Void))
}

extension CameraPromptingDelegate {
    func showCameraPermissionsDenied() {
        let action = AlertAction(
            title: LocalizationConstants.goToSettings,
            style: .confirm
        )
        let model = AlertModel(
            headline: LocalizationConstants.Errors.cameraAccessDenied,
            body: LocalizationConstants.Errors.cameraAccessDeniedMessage,
            actions: [action]
        )
        let alert = AlertView.make(with: model) { output in
            switch output.style {
            case .confirm:
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(settingsURL)
            case .default:
                break
            }
        }
        alert.show()
    }

    func promptToAcceptCameraPermissions(confirmHandler: @escaping (() -> Void)) {
        let okay = AlertAction(
            title: LocalizationConstants.okString,
            style: .confirm
        )
        let notNow = AlertAction(
            title: LocalizationConstants.KYC.notNow,
            style: .default
        )

        let model = AlertModel(
            headline: LocalizationConstants.KYC.allowCameraAccess,
            body: LocalizationConstants.KYC.enableCameraDescription,
            actions: [okay, notNow]
        )
        let alert = AlertView.make(with: model) { output in
            switch output.style {
            case .confirm:
                confirmHandler()
            case .default:
                break
            }
        }
        alert.show()
    }
}
