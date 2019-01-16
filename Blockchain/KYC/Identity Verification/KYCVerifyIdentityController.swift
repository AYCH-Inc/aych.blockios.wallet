//
//  KYCVerifyIdentityController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Veriff
import RxSwift
import UIKit

/// Account verification screen in KYC flow
final class KYCVerifyIdentityController: KYCBaseViewController {
    
    enum VerificationProviders {
        case veriff
    }
    
    private static let veriffVersion: String = "/v1/"

    // MARK: Factory

    override class func make(with coordinator: KYCCoordinator) -> KYCVerifyIdentityController {
        let controller = makeFromStoryboard()
        controller.coordinator = coordinator
        controller.pageType = .verifyIdentity
        return controller
    }

    // MARK: - Views

    @IBOutlet private var nextButton: PrimaryButtonContainer!

    // MARK: - Properties
    
    private let veriffService = VeriffService()
    private let veriff: Veriff = {
        return Veriff.sharedInstance()
    }()
    private var veriffCredentials: VeriffCredentials?

    private let currentProvider = VerificationProviders.veriff

    private var countryCode: String?

    private var disposable: Disposable?

    private lazy var presenter: KYCVerifyIdentityPresenter = { [unowned self] in
        let interactor = KYCVerifyIdentityInteractor()
        return KYCVerifyIdentityPresenter(interactor: interactor, view: self)
    }()

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    // MARK: - KYCCoordinatorDelegate

    override func apply(model: KYCPageModel) {
        guard case let .verifyIdentity(countryCode) = model else { return }
        self.countryCode = countryCode
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.actionBlock = { [unowned self] in
            guard let countryCode = self.countryCode else {
                return
            }
            switch self.currentProvider {
            case .veriff:
                self.startVerificationFlow()
            }
        }
    }

    // MARK: - Private Methods
    
    func veriffCredentialsRequest() {
        disposable = veriffService.createCredentials()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] credentials in
                guard let this = self else { return }
                this.veriffCredentials = credentials
                this.launchVeriffController()
                }, onError: { error in
                    Logger.shared.error("Failed to get Veriff credentials. Error: \(error.localizedDescription)")
            })
    }

    /// Begins identity verification and presents the view
    ///
    /// - Parameters:
    ///   - document: enum of identity types mapped to an identity provider
    ///   - provider: the current provider of verification services
    fileprivate func startVerificationFlow(_ document: KYCDocumentType? = nil, provider: VerificationProviders = .veriff) {
        switch provider {
        case .veriff:
            veriffCredentialsRequest()
        }
    }

    private func didSelect(_ document: KYCDocumentType) {
        startVerificationFlow(document, provider: currentProvider)
    }
    
    private func launchVeriffController() {
        guard veriffCredentials != nil else {
            Logger.shared.warning("Cannot launch VeriffController.")
            return
        }
        
        Veriff.configure { [weak self] configuration in
            guard let this = self else { return }
            guard let token = this.veriffCredentials?.key else { return }
            guard let value = this.veriffCredentials?.url else { return }
            guard var url = URL(string: value) else { return }
            
            /// Other clients have different SDK behaviors and expect that the
            /// `sessionURL` include the `sessionToken` as a parameter. Also
            /// some clients don't need the version number as a parameter. iOS
            /// does, otherwise we get a server error.
            if url.lastPathComponent != KYCVerifyIdentityController.veriffVersion {
                var components = URLComponents(string: value)
                components?.path = KYCVerifyIdentityController.veriffVersion
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
                this.showErrorMessage(LocalizationConstants.Errors.cameraAccessDeniedMessage)
            case .STATUS_ERROR_SESSION,
                 .STATUS_ERROR_NETWORK,
                 .STATUS_ERROR_UNKNOWN:
                this.showErrorMessage(LocalizationConstants.Errors.genericError)
            case .STATUS_DONE,
                 .STATUS_SUBMITTED,
                 .STATUS_ERROR_NO_IDENTIFICATION_METHODS_AVAILABLE:
                // DONE: The client got declined while he was still using the SDK
                // - this status can only occur if video_feature is used and FCM token is set.
                // NO_IDENTIFICATION: The session status is finished from clients perspective.
                this.veriffSubmissionCompleted()
            case .STATUS_VIDEO_CALL_ENDED,
                 .UNABLE_TO_RECORD_AUDIO,
                 .STATUS_OUT_OF_BUSINESS_HOURS,
                 .STATUS_USER_CANCELED:
                LoadingViewPresenter.shared.hideBusyView()
                this.dismiss(animated: true, completion: {
                    this.coordinator.handle(event: .nextPageFromPageType(this.pageType, nil))
                })
            }
        }
        
        veriff.requestViewController { [weak self] controller in
            guard let this = self else { return }
            this.present(controller, animated: true, completion: nil)
        }
    }
    
    private func veriffSubmissionCompleted() {
        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.KYC.submittingInformation)
        guard let credentials = veriffCredentials else { return }
        _ = veriffService.submitVerification(applicantId: credentials.applicantId)
            .do(onDispose: { LoadingViewPresenter.shared.hideBusyView() })
            .subscribe(
                onCompleted: { [unowned self] in
                    self.dismiss(animated: true, completion: {
                    self.coordinator.handle(event: .nextPageFromPageType(self.pageType, nil))
                })},
                onError: { error in
                    self.dismiss(animated: true, completion: {
                        AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
                    })
                    Logger.shared.error("Failed to submit verification \(error.localizedDescription)")
            })
    }
}

extension KYCVerifyIdentityController: KYCVerifyIdentityView {
    func showLoadingIndicator() {
        nextButton.isLoading = true
    }

    func hideLoadingIndicator() {
        nextButton.isLoading = false
    }

    func showDocumentTypesActionSheet(_ types: [KYCDocumentType]) {
        let documentDialog = UIAlertController(title: LocalizationConstants.KYC.whichDocumentAreYouUsing, message: nil, preferredStyle: .actionSheet)
        types.forEach { documentType  in
            let action = UIAlertAction(title: documentType.description, style: .default, handler: { [unowned self] _ in
                self.didSelect(documentType)
            })
            documentDialog.addAction(action)
        }
        documentDialog.addAction(UIAlertAction(title: LocalizationConstants.cancel, style: .cancel))
        present(documentDialog, animated: true)
    }

    func showErrorMessage(_ message: String) {
        AlertViewPresenter.shared.standardError(message: message)
    }
}
