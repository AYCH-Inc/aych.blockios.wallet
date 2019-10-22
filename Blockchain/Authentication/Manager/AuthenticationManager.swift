//
//  AuthenticationManager.swift
//  Blockchain
//
//  Created by Maurice A. on 2/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LocalAuthentication
import PlatformKit
import PlatformUIKit

enum BiometricsType {
    case touchId
    case faceId
    case none

    @available(iOS 11.0, *)
    static func create(from systemType: LABiometryType) -> BiometricsType {
        switch systemType {
        case .faceID:
            return .faceId
        case .touchID:
            return .touchId
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    var isValid: Bool {
        return self != .none
    }
}

/// Indicates the current biometrics configuration state
enum BiometricsStatus {
    
    /// Not configured on device but there is no restriction for configuring one
    case configurable(BiometricsType)
    
    /// Configured on the device and in app
    case configured(BiometricsType)
    
    /// Cannot be configured because the device do not support it,
    /// or because the user hasn't enabled it, or because that feature is not remotely
    case unconfigurable
    
    /// Returns `true` if biometrics is configurable
    var isConfigurable: Bool {
        switch self {
        case .configurable:
            return true
        case .configured, .unconfigurable:
            return false
        }
    }
    
    /// Returns `true` if biometrics is configured
    var isConfigured: Bool {
        switch self {
        case .configured:
            return true
        case .configurable, .unconfigurable:
            return false
        }
    }
    
    /// Returns associated `BiometricsType` if any
    var biometricsType: BiometricsType {
        switch self {
        case .configurable(let type):
            return type
        case .configured(let type):
            return type
        case .unconfigurable:
            return .none
        }
    }
}

/**
 Handles biometric and passcode authentication.
 # Usage
 Call either `authenticateUsingBiometrics(andReply:)` or `authenticate(using:andReply:)`
 to request authentication using biometrics or passcode, respectively.
 - Author: Maurice Achtenhagen
 - Copyright: Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
*/
@objc
final class AuthenticationManager: NSObject, AuthenticationManagerProtocol {

    // MARK: - Properties

    /// The instance variable used to access functions of the `AuthenticationManager` class.
    static let shared = AuthenticationManager()

    @objc class func sharedInstance() -> AuthenticationManager { return shared }

    /**
     The type alias for the closure used in:
     * `authenticate(using:andReply:)`
     */
    typealias WalletAuthHandler = (_ authenticated: Bool, _ twoFactorType: AuthenticationTwoFactorType?, _ error: AuthenticationError?) -> Void
    
    /**
     Used as a fallback for all other errors in:
     * `preFlightError(forBiometryError:)`
     * `preFlightError(forDeprecatedError:)`
     * `authenticationError(forError:)`
    */
    private let genericAuthenticationError: AuthenticationError = AuthenticationError(
        code: Int.min,
        description: LocalizationConstants.Biometrics.genericError
    )

    /// The app-provided reason for requesting authentication, which displays in the authentication dialog presented to the user.
    private lazy var authenticationReason: String = {
        return LocalizationConstants.Biometrics.authenticationReason
    }()

    /// The error object used prior to policy evaluation.
    var preflightError: NSError?

    /// The handler invoked during wallet authentication
    private var authHandler: WalletAuthHandler?

    private let walletManager: WalletManager
    private let featureConfigurator: AppFeatureConfigurator
    private let appSettings: BlockchainSettings.App
    private let loadingViewPresenter: LoadingViewPresenting

    /// Returns the status of biometrics configuration on the app and device
    var biometricsConfigurationStatus: BiometricsStatus {
        
        // Bioemtrics is enabled on the device
        guard canAuthenticateUsingBiometry else {
            return .unconfigurable
        }
        
        // Biometrics is enabled as a feature
        guard featureConfigurator.configuration(for: .biometry).isEnabled else {
            return .unconfigurable
        }
        
        // Biometrics id is already configured - therefore, return it
        if appSettings.biometryEnabled {
            return .configured(supportedBiometricsType)
        } else { // Biometrics has not yet been configured within the app
            return .configurable(supportedBiometricsType)
        }
    }
    
    /// Returns the configured biometrics, if any
    var configuredBiometricsType: BiometricsType {
        let status = biometricsConfigurationStatus
        if status.isConfigured {
            return status.biometricsType
        } else {
            return .none
        }
    }
    
    /// Returns the supported device biometrics, regardless if currently configured in app
    var supportedBiometricsType: BiometricsType {
        let context = LAContext()
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if #available(iOS 11, *), context.responds(to: #selector(getter: LAContext.biometryType)) {
            return .create(from: context.biometryType)
        } else if canEvaluate {
            return .touchId
        } else {
            return .none
        }
    }
    
    // MARK: Setup

    init(walletManager: WalletManager = .shared,
         featureConfigurator: AppFeatureConfigurator = .shared,
         appSettings: BlockchainSettings.App = .shared,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared) {
        self.walletManager = walletManager
        self.featureConfigurator = featureConfigurator
        self.appSettings = appSettings
        self.loadingViewPresenter = loadingViewPresenter
        super.init()
        walletManager.authDelegate = self
    }

    /// Deprecate this method once the wallet creation process has been refactored
    func setAuthCoordinatorAsCreationHandler() {
        authHandler = AuthenticationCoordinator.shared.authHandler
    }

    // MARK: - Authentication with Biometrics

    /**
     Authenticates the user using biometrics.
     - Parameter handler: The closure for the authentication reply.
     */
    func authenticateUsingBiometrics(andReply handler: @escaping BiometricsAuthHandler) {
        let context = LAContext()
        context.localizedFallbackTitle = LocalizationConstants.Biometrics.usePasscode
        context.localizedCancelTitle = LocalizationConstants.cancel
        if !canAuthenticateUsingBiometry {
            handler(false, preFlightError(forError: preflightError!.code)); return
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: authenticationReason,
                               reply: { [unowned self] authenticated, error in
            DispatchQueue.main.async {
                if let authError = error {
                    handler(false, self.authenticationError(forError: authError)); return
                }
                handler(authenticated, nil)
            }
        })
    }

    /// Evaluates whether the device owner can authenticate using biometrics.
    ///
    /// - Parameter handler: invoked with an AuthenticationError if the user cannot authenticate using biometrics, otherwise, nil
    @objc func canAuthenticateUsingBiometry(andReply handler: @escaping ((_ success: Bool, _ errorMessage: String?) -> Void)) {
        guard canAuthenticateUsingBiometry else {
            handler(false, preFlightError(forError: preflightError!.code).description)
            return
        }
        handler(true, nil)
    }

    /**
     Evaluates whether the device owner can authenticate using biometrics.
     */
    var canAuthenticateUsingBiometry: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &preflightError)
    }
    
    // MARK: - Authentication with Passcode

    /**
     The function used to authenticate the user using a provided passcode.
     - Parameters:
        - payload: The passcode payload used for authenticating the user.
        - handler: The completion handler for the authentication reply.
     */
    func authenticate(using payload: PasscodePayload, andReply handler: @escaping WalletAuthHandler) {
        guard Reachability.hasInternetConnection() else {
            handler(false, nil, AuthenticationError(code: AuthenticationError.ErrorCode.noInternet.rawValue))
            return
        }

        guard payload.password.isEmpty == false else {
            handler(false, nil, AuthenticationError(
                code: AuthenticationError.ErrorCode.noPassword.rawValue,
                description: LocalizationConstants.Authentication.noPasswordEntered
            ))
            return
        }

        authHandler = handler
        
        loadingViewPresenter.showCircular(with: LocalizationConstants.Authentication.loadingWallet)

        walletManager.wallet.load(withGuid: payload.guid, sharedKey: payload.sharedKey, password: payload.password)
    }

    // MARK: - Authentication Errors

    /**
     Preflight errors occur **prior** to policy evaluation.
     - Parameter code: The preflight error code.
     - Returns: An object of type `AuthenticationError` associated with the error code.
     - Important: When the description is nil, the error should be handled silently.
     */
    private func preFlightError(forError code: Int) -> AuthenticationError {
        if #available(iOS 11.0, *) {
            return preFlightError(forBiometryError: code)
        }
        return preFlightError(forDeprecatedError: code)
    }

    /**
     Biometric preflight errors occur **prior** to policy evaluation.
     - Parameter code: The preflight error code.
     - Returns: An object of type `AuthenticationError` associated with the error code.
     - Important: When the description is nil, the error should be handled silently.
     */
    private func preFlightError(forBiometryError code: Int) -> AuthenticationError {
        if #available(iOS 11.0, *) {
            switch code {
            case LAError.biometryLockout.rawValue:
                return AuthenticationError(code: code, description: LocalizationConstants.Biometrics.biometricsLockout)
            case LAError.biometryNotAvailable.rawValue:
                return AuthenticationError(code: code, description: LocalizationConstants.Biometrics.biometricsNotSupported)
            case LAError.biometryNotEnrolled.rawValue:
                // Update this string if we ever enable face ID
                return AuthenticationError(code: code, description: LocalizationConstants.Biometrics.touchIDEnableInstructions)
            default:
                return genericAuthenticationError
            }
        }
        return genericAuthenticationError
    }

    /**
     Deprecated preflight errors occur **prior** to policy evaluation.
     - Parameter code: The preflight error code.
     - Returns: An object of type `AuthenticationError` associated with the error code.
     - Important: When the description is nil, the error should be handled silently.
     */
    private func preFlightError(forDeprecatedError code: Int) -> AuthenticationError {
        switch code {
        case LAError.touchIDLockout.rawValue:
            return AuthenticationError(code: code, description: LocalizationConstants.Biometrics.touchIDLockout)
        case LAError.touchIDNotAvailable.rawValue:
            return AuthenticationError(code: code, description: LocalizationConstants.Biometrics.biometricsNotSupported)
        case LAError.touchIDNotEnrolled.rawValue:
            return AuthenticationError(code: code, description: LocalizationConstants.Biometrics.touchIDEnableInstructions)
        default:
            return genericAuthenticationError
        }
    }

    /**
     Inflight error codes that can be returned **during** policy evaluation.
     - Parameter code: The preflight error code.
     - Returns: An object of type `AuthenticationError` associated with the error code.
     - Important: When the description is nil, the error should be handled silently.
     */
    private func authenticationError(forError code: Error) -> AuthenticationError {
        switch code {
        case LAError.authenticationFailed:
            return AuthenticationError(
                code: LAError.authenticationFailed.rawValue,
                description: LocalizationConstants.Biometrics.authenticationFailed
            )
        case LAError.appCancel:
            return AuthenticationError(code: LAError.appCancel.rawValue, description: nil)
        case LAError.passcodeNotSet:
            return AuthenticationError(code: LAError.passcodeNotSet.rawValue, description: LocalizationConstants.Biometrics.passcodeNotSet)
        case LAError.systemCancel:
            return AuthenticationError(code: LAError.systemCancel.rawValue, description: nil)
        case LAError.userCancel:
            return AuthenticationError(code: LAError.userCancel.rawValue, description: nil)
        case LAError.userFallback:
            return AuthenticationError(code: LAError.userFallback.rawValue, description: nil)
        default:
            return genericAuthenticationError
        }
    }
}

extension AuthenticationManager: WalletAuthDelegate {
    func didDecryptWallet(guid: String?, sharedKey: String?, password: String?) {

        // Verify valid GUID and sharedKey
        guard let guid = guid, guid.count == 36 else {
            failAuth(withError: AuthenticationError(
                code: AuthenticationError.ErrorCode.errorDecryptingWallet.rawValue,
                description: LocalizationConstants.Authentication.errorDecryptingWallet
            ))
            return
        }

        guard let sharedKey = sharedKey, sharedKey.count == 36 else {
            failAuth(withError: AuthenticationError(
                code: AuthenticationError.ErrorCode.invalidSharedKey.rawValue,
                description: LocalizationConstants.Authentication.invalidSharedKey
            ))
            return
        }

        BlockchainSettings.App.shared.guid = guid
        BlockchainSettings.App.shared.sharedKey = sharedKey

        clearPinIfNeeded(for: password)
    }

    private func clearPinIfNeeded(for password: String?) {
        // Because we are not storing the password on the device. We record the first few letters of the hashed password.
        // With the hash prefix we can then figure out if the password changed. If so, clear the pin
        // so that the user can reset it
        guard let password = password,
            let passwordPartHash = password.passwordPartHash,
            let savedPasswordPartHash = BlockchainSettings.App.shared.passwordPartHash else {
                return
        }

        guard passwordPartHash != savedPasswordPartHash else {
            return
        }

        BlockchainSettings.App.shared.clearPin()
    }

    func didRequireTwoFactorAuth(withType type: AuthenticationTwoFactorType) {
        authHandler?(false, type, nil)
    }

    func emailAuthorizationRequired() {
        authHandler?(false, nil, AuthenticationError(
            code: AuthenticationError.ErrorCode.emailAuthorizationRequired.rawValue
        ))
    }

    func didResendTwoFactorSMSCode() {
        authHandler?(false, .sms, nil)
    }

    func authenticationError(error: AuthenticationError?) {
        failAuth(withError: error)
    }

    func authenticationCompleted() {
        authHandler?(true, nil, nil)
        authHandler = nil
    }

    private func failAuth(withError error: AuthenticationError? = nil) {
        authHandler?(false, nil, error)
        authHandler = nil
    }
}
