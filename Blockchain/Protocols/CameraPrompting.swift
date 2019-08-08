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
    var cameraPromptingDelegate: CameraPromptingDelegate? { get set }

    // Call this when an action requires camera usage
    func willUseCamera()

    func requestCameraPermissions()
}

extension CameraPrompting where Self: MicrophonePrompting {
    func willUseCamera() {
        if PermissionsRequestor.shouldDisplayCameraPermissionsRequest() {
            cameraPromptingDelegate?.promptToAcceptCameraPermissions(confirmHandler: {
                self.requestCameraPermissions()
            })
            return
        }
        if PermissionsRequestor.cameraRefused() == false {
            willUseMicrophone()
        } else {
            cameraPromptingDelegate?.showCameraPermissionsDenied()
        }
    }

    func requestCameraPermissions() {
        permissionsRequestor.requestPermissions([.camera]) { [weak self] in
            guard let this = self else { return }
            switch PermissionsRequestor.cameraEnabled() {
            case true:
                this.willUseMicrophone()
            case false:
                this.cameraPromptingDelegate?.showCameraPermissionsDenied()
            }
        }
    }
}

protocol CameraPromptingDelegate: class {
    func showCameraPermissionsDenied()
    func promptToAcceptCameraPermissions(confirmHandler: @escaping (() -> Void))
}

protocol MicrophonePromptingDelegate: class {
    func onMicrophonePromptingComplete()
    func promptToAcceptMicrophonePermissions(confirmHandler: @escaping (() -> Void))
}

extension MicrophonePromptingDelegate {
    func promptToAcceptMicrophonePermissions(confirmHandler: @escaping (() -> Void)) {
        let okay = AlertAction(style: .confirm(LocalizationConstants.okString))
        let notNow = AlertAction(style: .default(LocalizationConstants.KYC.notNow))
        
        let model = AlertModel(
            headline: LocalizationConstants.KYC.allowMicrophoneAccess,
            body: LocalizationConstants.KYC.enableMicrophoneDescription,
            actions: [okay, notNow]
        )
        let alert = AlertView.make(with: model) { output in
            switch output.style {
            case .confirm,
                 .default:
                confirmHandler()
            case .dismiss:
                break
            }
        }
        alert.show()
    }
}

extension CameraPromptingDelegate {
    func showCameraPermissionsDenied() {
        let action = AlertAction(style: .confirm(LocalizationConstants.goToSettings))
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
            case .default,
                 .dismiss:
                break
            }
        }
        alert.show()
    }

    func promptToAcceptCameraPermissions(confirmHandler: @escaping (() -> Void)) {
        let okay = AlertAction(style: .confirm(LocalizationConstants.okString))
        let notNow = AlertAction(style: .default(LocalizationConstants.KYC.notNow))
        
        let model = AlertModel(
            headline: LocalizationConstants.KYC.allowCameraAccess,
            body: LocalizationConstants.KYC.enableCameraDescription,
            actions: [okay, notNow]
        )
        let alert = AlertView.make(with: model) { output in
            switch output.style {
            case .confirm:
                confirmHandler()
            case .default,
                 .dismiss:
                break
            }
        }
        alert.show()
    }
}
