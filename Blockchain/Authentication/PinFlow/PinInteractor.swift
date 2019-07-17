//
//  PinScreenInteractor.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// Interactor for the pin. This component interacts with the Blockchain API and the local
/// pin data store. When the pin is updated, the pin is also stored on the keychain.
final class PinInteractor: PinInteracting {

    // MARK: - Properties
    
    private let pinService: PinServicing
    private let maintenanceService: MaintenanceServicing
    private let wallet: WalletProtocol
    private let appSettings: AppSettingsAuthenticating
    private let recorder: ErrorRecording
    
    // MARK: - Setup
    
    init(pinService: PinServicing = PinService(),
         maintenanceService: MaintenanceServicing = WalletService.shared,
         wallet: WalletProtocol = WalletManager.shared.wallet,
         appSettings: AppSettingsAuthenticating = BlockchainSettings.App.shared,
         recorder: ErrorRecording = CrashlyticsRecorder()) {
        self.pinService = pinService
        self.maintenanceService = maintenanceService
        self.wallet = wallet
        self.appSettings = appSettings
        self.recorder = recorder
    }
    
    // MARK: - API

    /// Creates a pin code in the remote pin store
    /// - Parameter payload: the pin payload
    /// - Returns: Completable indicating completion
    func create(using payload: PinPayload) -> Completable {
        return maintenanceService.serverUnderMaintenanceMessage
            .flatMap(weak: self) { (self, message) -> Single<PinStoreResponse> in
                if let message = message { throw PinError.serverMaintenance(message: message) }
                return self.pinService.create(pinPayload: payload)
            }
            .do(onSuccess: { [weak self] response in
                try self?.handleCreatePinResponse(response: response, payload: payload)
            })
            .catchError { error in
                throw PinError.map(from: error)
            }
            .asCompletable()
    }
    
    /// Validates if the provided pin payload (i.e. pin code and pin key combination) is correct.
    /// Calling this method will also fetch the WalletOptions to see if the server is under maintenance,
    /// then, handle updating the local pin store (i.e. the keychain),
    /// depending on the response for the remote pin store.
    /// - Parameter payload: the pin payload
    /// - Returns: Single warpping the pin decryption key
    func validate(using payload: PinPayload) -> Single<String> {
        return maintenanceService.serverUnderMaintenanceMessage
            .flatMap(weak: self) { (self, message) -> Single<String> in
                if let message = message { throw PinError.serverMaintenance(message: message) }
                return self.pinService.validate(pinPayload: payload)
                    .do(onSuccess: { [weak self] response in
                        self?.updateCacheIfNeeded(response: response, pinPayload: payload)
                    })
                    .map { [weak self] response -> String in
                        guard let self = self else { throw PinError.unretainedSelf }
                        return try self.pinValidationStatus(from: response)
                }
            }
            .catchError { error in
                throw PinError.map(from: error)
        }
    }
    
    /// Keep the PIN value on the local pin store (i.e the keychain), for biometrics auth.
    /// - Parameter pin: the pin value
    func persist(pin: Pin) {
        pin.save(using: appSettings)
        appSettings.biometryEnabled = true
    }
    
    // MARK: - Accessors

    private func handleCreatePinResponse(response: PinStoreResponse,
                                         payload: PinPayload) throws {
        // Wallet must have password at the stage
        guard let password = wallet.password else {
            let error = PinError.serverError(LocalizationConstants.Pin.cannotSaveInvalidWalletState)
            recorder.error(error)
            throw error
        }
        
        guard response.error == nil else {
            recorder.error(PinError.serverError(""))
            throw PinError.serverError(response.error!)
        }

        guard response.isSuccessful else {
            let message = String(
                format: LocalizationConstants.Errors.invalidStatusCodeReturned,
                response.statusCode?.rawValue ?? -1
            )
            let error = PinError.serverError(message)
            recorder.error(error)
            throw error
        }

        guard let pinValue = payload.pinValue,
            !payload.pinKey.isEmpty,
            !pinValue.isEmpty else {
                let error = PinError.serverError(LocalizationConstants.Pin.responseKeyOrValueLengthZero)
                recorder.error(error)
                throw error
        }
        
        // Once the pin has been created successfully, the wallet is not longer marked as new.
        wallet.isNew = false

        // Encrypt the wallet password with the random value
        let encryptedPinPassword = wallet.encrypt(password, password: pinValue)

        // Update the cache
        appSettings.encryptedPinPassword = encryptedPinPassword
        appSettings.pinKey = payload.pinKey
        appSettings.passwordPartHash = password.passwordPartHash
        
        updateCacheIfNeeded(response: response, pinPayload: payload)
    }

    /// Persists the pin if needed or deletes it according to the response code received from the backend
    private func updateCacheIfNeeded(response: PinStoreResponse,
                                     pinPayload: PinPayload) {
        guard let responseCode = response.statusCode else { return }
        switch responseCode {
        case .success where pinPayload.persistsLocally:
            // Optionally save the pin to the keychain to enable biometric authenticators
            persist(pin: pinPayload.pin!)
        case .deleted:
            // Clear pin from keychain if the user exceeded the number of retries when entering the pin.
            appSettings.pin = nil
            appSettings.biometryEnabled = false
        default:
            break
        }
    }
    
    // Returns the pin decryption key, or throws error if cannot
    private func pinValidationStatus(from response: PinStoreResponse) throws -> String {
        
        // First verify that the status code was received
        guard let statusCode = response.statusCode else {
            let error = PinError.serverError(LocalizationConstants.Errors.genericError)
            recorder.error(error)
            throw error
        }
        
        switch statusCode {
        case .deleted:
            throw PinError.tooManyAttempts
        case .incorrect:
            let message = response.error ?? LocalizationConstants.Pin.incorrect
            throw PinError.incorrectPin(message)
        case .success:
            guard let pinDecryptionKey = response.pinDecryptionValue, !pinDecryptionKey.isEmpty else {
                throw PinError.custom(LocalizationConstants.Errors.genericError)
            }
            return pinDecryptionKey
        }
    }
}
