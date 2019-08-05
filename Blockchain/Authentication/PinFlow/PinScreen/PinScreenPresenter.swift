//
//  PinCodeViewModel.swift
//  Blockchain
//
//  Created by Daniel Huri on 08/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import PlatformKit
import PlatformUIKit
import LocalAuthentication

/// Presenter for PIN screen
final class PinScreenPresenter {
    
    // MARK: - Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        switch flow {
        case .create:
            return .content(Screen.NavigationBarContent(title: "v\(Bundle.applicationVersion ?? "")"))
        case .authenticate(from: let origin, logoutRouting: _):
            switch origin {
            case .background:
                return .content(Screen.NavigationBarContent(title: "v\(Bundle.applicationVersion ?? "")"))
            case .foreground:
                return .none
            }
        default:
            return .none
        }
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        switch flow {
        case .authenticate(from: let origin, logoutRouting: _):
            switch origin {
            case .background:
                return .text(value: LocalizationConstants.Pin.logoutButton)
            case .foreground:
                return .none
            }
        case .change, .enableBiometrics:
            return .back
        case .create:
            return .none
        }
    }
    
    var titleView: Screen.Style.TitleView {
        switch flow {
        case .change:
            return .text(value: LocalizationConstants.Pin.changePinTitle)
        default:
            return .image(name: "logo_large", width: 40)
        }
    }
    
    var barStyle: Screen.Style.Bar {
        switch flow {
        case .authenticate(from: .background, logoutRouting: _):
            return .lightContent(ignoresStatusBar: true, background: .clear)
        case .change(logoutRouting: _):
            return .lightContent(ignoresStatusBar: false, background: .primary)
        default:
            return .lightContent(ignoresStatusBar: false, background: .clear)
        }
    }

    let contentColor: UIColor
    let backgroundColor: UIColor

    // MARK: Rx
    
    private let disposeBag = DisposeBag()
    
    private let pinProcessingObservable: Observable<Pin>
    let pin = BehaviorRelay<Pin?>(value: nil)
    
    private let isProcessingRelay = BehaviorRelay<Bool>(value: false)
    
    /// When `true`, the the presenter is pending for an update from the interactor
    var isProcessing: Observable<Bool> {
        return isProcessingRelay
            .observeOn(MainScheduler.instance)
    }
    
    // MARK: Routing
    
    private let forwardRouting: PinRouting.RoutingType.Forward
    let backwardRouting: PinRouting.RoutingType.Backward!

    // MARK: Services
    
    private let interactor: PinInteracting
    private let recorder: Recording
    private let appSettings: AppSettingsAuthenticating & SwipeToReceiveConfiguring
    private let authenticationManager: AuthenticationManagerProtocol
    
    // MARK: - View Models
    
    let digitPadViewModel: DigitPadViewModel
    let securePinViewModel: SecurePinViewModel
    
    /// The flow which `useCase` is under
    let flow: PinRouting.Flow
    
    /// The use case for the screen
    let useCase: PinScreenUseCase
    
    /// Returns `true` in case the flow should show swipe to receive button
    var showsSwipeToReceive: Bool {
        return useCase.isAuthenticateOnLogin && appSettings.swipeToReceiveEnabled
    }
    
    // MARK: - Setup
    
    init(useCase: PinScreenUseCase,
         flow: PinRouting.Flow,
         interactor: PinInteracting = PinInteractor(),
         authenticationManager: AuthenticationManagerProtocol = AuthenticationManager.shared,
         appSettings: AppSettingsAuthenticating & SwipeToReceiveConfiguring = BlockchainSettings.App.shared,
         recorder: Recording = CrashlyticsRecorder(),
         backwardRouting: PinRouting.RoutingType.Backward? = nil,
         forwardRouting: @escaping PinRouting.RoutingType.Forward) {
        self.useCase = useCase
        self.flow = flow
        self.interactor = interactor
        self.recorder = recorder
        self.appSettings = appSettings
        self.authenticationManager = authenticationManager
        self.backwardRouting = backwardRouting
        self.forwardRouting = forwardRouting

        let emptyPinColor: UIColor
        let buttonHighlightColor: UIColor
        switch flow {
        case .change:
            contentColor = .primary
            backgroundColor = .white
            emptyPinColor = .securePinGrey
            buttonHighlightColor = UIColor.black.withAlphaComponent(0.08)
        case .authenticate, .create, .enableBiometrics:
            contentColor = .white
            backgroundColor = .primary
            emptyPinColor = UIColor.white.withAlphaComponent(0.12)
            buttonHighlightColor = UIColor.white.withAlphaComponent(0.08)
        }
        
        // Setup the bottom leading button (biometrics) if necessary
        let customButtonViewModel: DigitPadButtonViewModel
        
        switch useCase {
        case .authenticateBeforeChanging, .authenticateOnLogin:
            let currentBiometricsType = authenticationManager.configuredBiometricsType
            if currentBiometricsType.isValid {
                let biometricButtonImage: DigitPadButtonViewModel.Content.Image!
                switch currentBiometricsType {
                case .faceId:
                    biometricButtonImage = .faceId
                case .touchId:
                    biometricButtonImage = .touchId
                case .none:
                    biometricButtonImage = nil
                }
                let buttonBackground = DigitPadButtonViewModel.Background(highlightColor: buttonHighlightColor)
                customButtonViewModel = DigitPadButtonViewModel(content: .image(type: biometricButtonImage, tint: contentColor),
                                                                       background: buttonBackground)
            } else {
                customButtonViewModel = .empty
            }
        case .authenticateBeforeEnablingBiometrics, .create, .select:
            customButtonViewModel = .empty
        }
        
        // Setup the subject
        let securePinTitle: String
        switch useCase {
        case .authenticateBeforeChanging, .authenticateBeforeEnablingBiometrics, .authenticateOnLogin:
            securePinTitle = LocalizationConstants.Pin.enterYourPinLabel
        case .select:
            securePinTitle = LocalizationConstants.Pin.createYourPinLabel
        case .create:
            securePinTitle = LocalizationConstants.Pin.confirmYourPinLabel
        }

        digitPadViewModel = DigitPadViewModel(customButtonViewModel: customButtonViewModel,
                                              contentTint: contentColor,
                                              buttonHighlightColor: buttonHighlightColor)
        securePinViewModel = SecurePinViewModel(title: securePinTitle,
                                                tint: contentColor,
                                                emptyPinColor: emptyPinColor)
        
        // Bind PIN length to fill count
        digitPadViewModel.valueLengthObservable
            .bind(to: securePinViewModel.fillCountRelay)
            .disposed(by: disposeBag)
        
        // Get the pin string once it's filled, map it to `Pin`, unwrap it.
        pinProcessingObservable = digitPadViewModel.valueInsertedObservable
            .withLatestFrom(digitPadViewModel.valueObservable)
            .map { Pin(string: $0) }
            .filter { $0 != nil }
            .map { $0! }
        
        // Bind pin processing to pin relay
        pinProcessingObservable
            .bind(to: pin)
            .disposed(by: disposeBag)
        
        // Bind tapping on the biometrics button to authentication using biometrics
        digitPadViewModel.customButtonTapObservable
            .bind { [unowned self] in
                self.authenticateUsingBiometricsIfNeeded()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Navigation

extension PinScreenPresenter {
    func leadingButtonPressed() {
        if !useCase.isAuthenticateOnLogin {
            backwardRouting()
        } else {
            logout()
        }
    }
    
    // TODO: Display an overlay for the pin
    func trailingButtonPressed() {}
}

// MARK: - API & Functionality

extension PinScreenPresenter {
    
    /// Resets the pin
    /// - parameter value: the value to reset the pin to
    func reset(to value: String = "") {
        digitPadViewModel.reset(to: value)
    }
    
    /// Authenticate using set biometrics
    func authenticateUsingBiometricsIfNeeded() {
        
        // Verify the use case is authentication
        guard useCase.isAuthenticate else {
            return
        }
        
        // Verify biometrics authenticators are enabled on device and configured in app
        guard authenticationManager.biometricsConfigurationStatus.isConfigured else {
            return
        }
        
        /*
         At this point, the PIN is assumed to have been kept on
         keychain so it MUST have value, otherwise, report a non-fatal
         */
        guard let pin = appSettings.pin else {
            recorder.error("Expected a valid pin value. Got `nil` instead!. flow: \(flow.debugDescription)")
            return
        }

        authenticationManager.authenticateUsingBiometrics { [weak self] authenticated, error in
            guard let self = self else { return }

            // Make sure authentication has passed successfully
            guard authenticated, error == nil else {
                return
            }
            
            // We reset the pin to the value kept by the app settings.
            // That causes a chain reaction as if the user has filled the pin himself.
            self.digitPadViewModel.reset(to: pin)
        }
    }
    
    // MARK: - Changing/First Time Setting Pin
    
    /// Validates that the 1st pin entered by the user during the change pin flow,
    /// or the first time the user is setting a pin, is valid.
    func validateFirstEntry() -> Completable {
        return Completable.create { [unowned self] completable in
            
            // Check for validity
            guard let pin = self.pin.value, pin.isValid else {
                completable(.error(PinError.invalid))
                return Disposables.create()
            }
            
            // Check that the current pin is different from the previous pin
            guard pin != self.useCase.pin else {
                completable(.error(PinError.identicalToPrevious))
                return Disposables.create()
            }
            
            // A completion to be executed in an case
            let completion = { [unowned self] in
                self.forwardRouting(.pin(value: pin))
                completable(.completed)
            }
                        
            completion()
            return Disposables.create()
        }
    }
    
    /// Validates that the 2nd pin entered during the create/change pin flow matches the
    /// 1st pin entered, and if so, it will proceed to change the user's pin.
    func validateSecondEntry() -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            // Extract both current and previous pins before comparing them. Both MUST NOT be nil at that point
            let previousPin = self.useCase.pin!
            let pin = self.pin.value!
            
            // Current pin must be equal to the previous pin
            guard pin == previousPin else {
                completable(.error(PinError.pinMismatch(recovery: self.backwardRouting)))
                return Disposables.create()
            }
            
            // Generate a random key-pair
            guard let keyPair = try? PinStoreKeyPair.generateNewKeyPair() else {
                completable(.error(PinError.custom(LocalizationConstants.Pin.genericError)))
                return Disposables.create()
            }
            
            // Create the pin payload
            let payload = PinPayload(pinCode: pin.toString,
                                     keyPair: keyPair,
                                     persistsLocally: self.authenticationManager.biometricsConfigurationStatus.isConfigured)
            
            self.isProcessingRelay.accept(true)
            
            // Create the pin in the remote store
            self.interactor.create(using: payload)
                .observeOn(MainScheduler.instance)
                .subscribe(onCompleted: { [weak self] in
                    self?.isProcessingRelay.accept(false)
                    completable(.completed)
                }, onError: { [weak self] error in
                    self?.isProcessingRelay.accept(false)
                    completable(.error(error))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    // Invoked when user is authenticating himself using his PIN, before selecting a new one
    func verifyPinBeforeChanging() -> Completable {
        
        // Pin MUST NOT be nil at that point as it accompanies the use-case.
        let pin = self.pin.value!

        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            self.verify()
                .asCompletable()
                .subscribe(onCompleted: { [weak self] in
                    self?.forwardRouting(.pin(value: pin))
                    completable(.completed)
                    }, onError: { error in
                        completable(.error(error))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    // Invoked when user is authenticating himself using pin or biometrics
    func authenticatePin() -> Completable {
        return verify()
            .do(onSuccess: { [weak self] decryptionKey in
                self?.forwardRouting(.authentication(pinDecryptionKey: decryptionKey))
            })
            .asCompletable()
    }
}

// MARK: - Accessors

extension PinScreenPresenter {
    
    /// Opts out the user
    func logout() {
        interactor.hasLogoutAttempted = true
        flow.logoutRouting?()
    }
    
    // Should be called after setting pin successfully
    func didSetPinSuccessfully() {
        forwardRouting(.pin(value: pin.value!))
    }
    
    // MARK: - Pin Validation
    
    /// Validates if the pin is correct, by generating payload (i.e. pin code and pin key combination)
    /// - Returns: Single warpping the pin decryption key
    private func verify() -> Single<String> {
        guard Reachability.hasInternetConnection() else {
            let reset = { [weak self] () -> Void in
                self?.reset()
            }
            return .error(PinError.noInternetConnection(recovery: reset))
        }
        
        guard let pinKey = appSettings.pinKey else {
            return .error(PinError.nullifiedPinKey)
        }
        
        // Pin MUST NOT be nil at that point
        let pin = self.pin.value!
        
        // Create a pin payload to be validated by the interactor
        let payload = PinPayload(pinCode: pin.toString,
                                 pinKey: pinKey,
                                 persistsLocally: useCase.isAuthenticateBeforeEnablingBiometrics)
        
        isProcessingRelay.accept(true)

        // Ask the interactor to validate the payload
        return interactor.validate(using: payload)
            .do(onSuccess: { [weak self] _ in
                self?.isProcessingRelay.accept(false)
            }, onError: { [weak self] error in
                self?.isProcessingRelay.accept(false)
            })
            .observeOn(MainScheduler.instance)
    }
}

// MARK: - Alert View Models

/// In order to separate the alert UI from the pin presenter,
/// the presenter only decides what alert model should be displayed
/// and returns it to the component that requested it.
extension PinScreenPresenter {
    
    /// Logout alert model
    var logoutAlertModel: AlertModel {
        let okButton = AlertAction(style: .confirm(LocalizationConstants.okString))
        let image = UIImage(named: "lock_icon")!
        return AlertModel(headline: LocalizationConstants.Pin.tooManyAttemptsTitle,
                          body: LocalizationConstants.Pin.tooManyAttemptsMessage,
                          actions: [okButton],
                          image: image,
                          style: .sheet)
    }
    
    /// Enabling biometrics alert model (if biometrics is configurable)
    var biometricsAlertModel: AlertModel? {
        let biometricsStatus = authenticationManager.biometricsConfigurationStatus
        
        // Ensure bioemtrics is configurable before continuing
        guard biometricsStatus.isConfigurable else {
            return nil
        }
        
        let okButtonAction = { [unowned self] in
            self.interactor.persist(pin: self.pin.value!)
        }
        let okButton = AlertAction(style: .confirm(LocalizationConstants.okString),
                                   metadata: .block(okButtonAction))
        let cancelButton = AlertAction(style: .default(LocalizationConstants.Pin.enableBiometricsNotNowButton))
        let title: String
        let image: UIImage
        switch biometricsStatus.biometricsType {
        case .faceId:
            title = LocalizationConstants.Pin.enableFaceIdTitle
            image = UIImage(named: "face_id_icon")!
        default: // touch-id
            title = LocalizationConstants.Pin.enableTouchIdTitle
            image = UIImage(named: "touch_id_icon")!
        }
        let alert = AlertModel(headline: title,
                               body: LocalizationConstants.Pin.enableBiometricsMessage,
                               actions: [okButton, cancelButton],
                               image: image.withRenderingMode(.alwaysTemplate),
                               style: .sheet)
        return alert
    }
    
    /// Set pin success alert model
    var setPinSuccessAlertModel: AlertModel? {
        guard flow.isChange else {
            return nil
        }
        
        let okButton = AlertAction(style: .confirm(LocalizationConstants.continueString))
        let image = UIImage(named: "success_icon")!
        let alert = AlertModel(headline: LocalizationConstants.Pin.pinSuccessfullySet,
                               body: "",
                               actions: [okButton],
                               image: image,
                               style: .sheet)
        return alert
    }
}
