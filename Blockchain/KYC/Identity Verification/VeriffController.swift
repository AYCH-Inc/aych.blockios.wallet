//
//  VeriffController.swift
//  Blockchain
//
//  Created by kevinwu on 1/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import Veriff

protocol VeriffController: class {

    var veriff: Veriff { get }

    // Actions

    func veriffCredentialsRequest()

    func launchVeriffController(credentials: VeriffCredentials, version: String)

    // Completion handlers

    func onVeriffSubmissionCompleted()

    func onVeriffError(message: String)

    func onVeriffCancelled()
}

extension VeriffController where Self: UIViewController {
    internal var veriff: Veriff {
        return Veriff.sharedInstance()
    }

    func launchVeriffController(credentials: VeriffCredentials, version: String) {

        Veriff.configure { [weak self] configuration in
            guard let this = self else { return }
            let token = credentials.key
            let value = credentials.url
            guard var url = URL(string: value) else { return }

            /// Other clients have different SDK behaviors and expect that the
            /// `sessionURL` include the `sessionToken` as a parameter. Also
            /// some clients don't need the version number as a parameter. iOS
            /// does, otherwise we get a server error.
            if url.lastPathComponent != version {
                var components = URLComponents(string: value)
                components?.path = version
                guard let modifiedURL = components?.url else { return }
                url = modifiedURL
            }
            configuration.sessionUrl = url.absoluteString
            configuration.sessionToken = token
        }

        Veriff.createColorSchema { schema in
            // TODO: Apply color scheme
        }

        veriff.setResultBlock { [weak self] _, result in
            guard let this = self else { return }
            switch result.code {
            case .UNABLE_TO_ACCESS_CAMERA:
                this.onVeriffError(message: LocalizationConstants.Errors.cameraAccessDeniedMessage)
            case .STATUS_ERROR_SESSION,
                 .STATUS_ERROR_NETWORK,
                 .STATUS_ERROR_UNKNOWN:
                this.onVeriffError(message: LocalizationConstants.Errors.genericError)
            case .STATUS_DONE,
                 .STATUS_SUBMITTED,
                 .STATUS_ERROR_NO_IDENTIFICATION_METHODS_AVAILABLE:
                // DONE: The client got declined while he was still using the SDK
                // - this status can only occur if video_feature is used and FCM token is set.
                // NO_IDENTIFICATION: The session status is finished from clients perspective.
                this.onVeriffSubmissionCompleted()
            case .STATUS_VIDEO_CALL_ENDED,
                 .UNABLE_TO_RECORD_AUDIO,
                 .STATUS_OUT_OF_BUSINESS_HOURS,
                 .STATUS_USER_CANCELED:
                LoadingViewPresenter.shared.hideBusyView()
                this.dismiss(animated: true, completion: {
                    this.onVeriffCancelled()
                })
            }
        }

        veriff.requestViewController { [weak self] controller in
            guard let this = self else { return }
            this.present(controller, animated: true, completion: nil)
        }
    }
}
