//
//  PinScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import PlatformUIKit

final class PinScreenViewController: BaseScreenViewController {
    
    // MARK: - Properties
    
    @IBOutlet private var swipeInstructionView: SwipeInstructionView!

    @IBOutlet private var digitPadView: DigitPadView!
    @IBOutlet private var securePinView: SecurePinView!
    @IBOutlet private var errorLabel: UILabel!

    @IBOutlet private var digitPadBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var securePinViewTopConstraint: NSLayoutConstraint!

    private let presenter: PinScreenPresenter
    private let devSupport: DevSupporting
    private let alertViewPresenter: AlertViewPresenter
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(using presenter: PinScreenPresenter,
         alertViewPresenter: AlertViewPresenter = .shared,
         devSupport: DevSupporting = AppCoordinator.shared) {
        self.presenter = presenter
        self.alertViewPresenter = alertViewPresenter
        self.devSupport = devSupport
        super.init(nibName: PinScreenViewController.className, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupErrorLabel()
        
        swipeInstructionView.isHidden = !presenter.showsSwipeToReceive
        digitPadView.viewModel = presenter.digitPadViewModel
        securePinView.viewModel = presenter.securePinViewModel

        if Constants.Booleans.isUsingScreenSizeEqualIphone5S {
            digitPadBottomConstraint.constant = 20
            securePinViewTopConstraint.constant = 5
        }
        
        // Subscribe to pin changes
        presenter.pin
            .bind { [weak self] pin in
                guard let pin = pin else { return }
                self?.respond(to: pin)
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.when(UIApplication.willEnterForegroundNotification) { [weak self] _ in
            self?.prepareForAppearance()
        }
    }
    
    private func prepareForAppearance() {
        presenter.reset()
        swipeInstructionView.setup(text: LocalizationConstants.Pin.swipeToReceiveLabel,
                                   font: Font(.branded(.montserratMedium), size: .custom(14)).result)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareForAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.authenticateUsingBiometricsIfNeeded()
        
        #if DEBUG
        becomeFirstResponder()
        #endif
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        parent?.view.backgroundColor = presenter.backgroundColor
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton)
        titleViewStyle = presenter.titleView
        
        // Subscribe to `isProcessing` indicates whether something is processing in the background 
        presenter.isProcessing
            .bind { [weak self] isProcessing in
                guard let self = self else { return }
                self.view.isUserInteractionEnabled = !isProcessing
                self.trailingButtonStyle = isProcessing ? .processing : self.presenter.trailingButton
            }
            .disposed(by: disposeBag)
    }
    
    private func setupErrorLabel() {
        errorLabel.accessibility = Accessibility(id: .value(AccessibilityIdentifiers.PinScreen.errorLabel))
        errorLabel.font = Font(.branded(.montserratLight), size: .standard(.small(.h2))).result
        errorLabel.textColor = presenter.contentColor
    }
    
    // MARK: - Navigation
    
    override func navigationBarLeftButtonPressed() {
        if presenter.useCase.isAuthenticateOnLogin {
            displayLogoutWarningAlert()
        } else {
            presenter.backwardRouting()
        }
    }
    
    override func navigationBarRightButtonPressed() {
        presenter.trailingButtonPressed()
    }
}

// MARK: - Presenter Interaction & Feedback

extension PinScreenViewController {
    
    /// Accepts a valid pin value
    private func respond(to pin: Pin) {
        errorLabel.alpha = 0
        switch presenter.useCase {
        case .select:
            selectPin()
        case .create:
            createPin()
        case .authenticateBeforeChanging:
            authenticatePinBeforeChanging()
        case .authenticateOnLogin, .authenticateBeforeEnablingBiometrics:
            authenticatePin()
        }
    }
    
    /// Handle any kind of error returned by the presenter
    private func handle(error: Error) {
        view.isUserInteractionEnabled = false
        let deferred = { [weak self] in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            self.presenter.reset()
        }
    
        var optionalRecovery: (() -> Void)?
        
        let error = PinError.map(from: error)
        switch error {
        case .pinMismatch(recovery: let recovery):
            showInlineError(with: LocalizationConstants.Pin.pinsDoNotMatch)
            optionalRecovery = recovery
        case .identicalToPrevious:
            showInlineError(with: LocalizationConstants.Pin.newPinMustBeDifferent)
        case .invalid:
            showInlineError(with: LocalizationConstants.Pin.chooseAnotherPin)
        case .incorrectPin(let message):
            showInlineError(with: message)
        case .tooManyAttempts:
            displayLogoutAlert()
        case .noInternetConnection(recovery: let recovery):
            alertViewPresenter.showNoInternetConnectionAlert(in: self, completion: recovery)
        case .serverMaintenance(message: let message):
            alertViewPresenter.standardError(message: message, in: self)
        case .serverError(message: let message):
            alertViewPresenter.standardError(message: message, in: self)
        case .custom(let message):
            alertViewPresenter.standardError(message: message, in: self)
        case .biometricAuthenticationFailed(let message):
            alertViewPresenter.standardError(message: message, in: self)
        default:
            showInlineError(with: LocalizationConstants.Pin.genericError)
        }

        UINotificationFeedbackGenerator().notificationOccurred(.error)
        let animator = securePinView.joltAnimator
        animator.addCompletion { _ in
            guard let optionalRecovery = optionalRecovery else {
                deferred()
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                deferred()
                optionalRecovery()
            }
        }
        animator.startAnimation()
    }
    
    private func showInlineError(with text: String) {
        errorLabel.text = text
        errorLabel.alpha = 1
    }
    
    /// Displays a logout warning alert when the user taps the `Log out` button
    private func displayLogoutWarningAlert() {
        let actions = [
            UIAlertAction(title: LocalizationConstants.okString, style: .default, handler: { [weak self] _ in
                self?.presenter.logout()
            }),
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        ]
        alertViewPresenter.standardNotify(
            message: LocalizationConstants.Pin.LogoutAlert.message,
            title: LocalizationConstants.Pin.LogoutAlert.title,
            actions: actions,
            in: self
        )
    }
    
    /// Displays alert telling the user he has exhausted the max allowed number of PIN retries.
    private func displayLogoutAlert() {
        let alertView = AlertView.make(with: presenter.logoutAlertModel) { [weak self] _ in
            self?.presenter.logout()
        }
        alertView.show()
    }
    
    private func displaySetPinSuccessAlertIfNeeded() {
        let success = { [weak presenter] in
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            presenter?.didSetPinSuccessfully()
        }
        
        guard let model = presenter.setPinSuccessAlertModel else {
            success()
            return
        }
        let alertView = AlertView.make(with: model) { _ in
            success()
        }
        alertView.show()
    }
    
    private func displayEnableBiometricsAlertIfNeeded(completion: @escaping () -> Void) {
        guard let model = presenter.biometricsAlertModel else {
            completion()
            return
        }
        let alertView = AlertView.make(with: model) { action in
            switch action.metadata {
            case .some(.block(let block)):
                block()
            default:
                break
            }
            completion()
        }
        alertView.show()
    }
    
    /// Called after setting the pin successfully on both create & change flows
    private func setPinSuccess() {
        displayEnableBiometricsAlertIfNeeded { [weak self] in
            self?.displaySetPinSuccessAlertIfNeeded()
        }
    }
    
    // Invoked upon first selection of PIN (creation / change flow)
    private func selectPin() {
        presenter.validateFirstEntry()
            .subscribe(onError: { [weak self] error in
                self?.handle(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    // Invoked upon creation of a new PIN (creation / change flow)
    private func createPin() {
        presenter.validateSecondEntry()
            .subscribe(onCompleted: { [weak self] in
                self?.setPinSuccess()
            }, onError: { [weak self] error in
                self?.handle(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    // Standard login authentication / before configuring biometrics
    private func authenticatePin() {
        presenter.authenticatePin()
            .subscribe(onCompleted: {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }, onError: { [weak self] error in
                self?.handle(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    // Authentication before choosing another pin
    private func authenticatePinBeforeChanging() {
        presenter.verifyPinBeforeChanging()
            .subscribe(onCompleted: {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }, onError: { [weak self] error in
                self?.handle(error: error)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - NavigationTransitionAnimating

extension PinScreenViewController: NavigationTransitionAnimating {
    func prepareForAppearance(for transition: ScreenTransitioningAnimator.TransitionType) {
        let joltOffset = presenter.securePinViewModel.joltOffset
        switch transition {
        case .pushIn:
            securePinView.transform = CGAffineTransform(translationX: -joltOffset, y: 0)
        case .pushOut:
            securePinView.transform = CGAffineTransform(translationX: joltOffset, y: 0)
        }
        securePinView.alpha = 0
    }
    
    func appearancePropertyAnimator(for transition: ScreenTransitioningAnimator.TransitionType) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: transition.duration * 0.5, curve: .easeOut)
        animator.addAnimations {
            self.securePinView.alpha = 1
            self.securePinView.transform = .identity
        }
        return animator
    }
    
    func disappearancePropertyAnimator(for transition: ScreenTransitioningAnimator.TransitionType) -> UIViewPropertyAnimator {
        let duration: TimeInterval = transition.duration * 0.5
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut)
        let joltOffset = presenter.securePinViewModel.joltOffset
        animator.addAnimations {
            self.securePinView.alpha = 0
            self.errorLabel.alpha = 0
            switch transition {
            case .pushIn:
                self.securePinView.transform = CGAffineTransform(translationX: joltOffset, y: 0)
            case .pushOut:
                self.securePinView.transform = CGAffineTransform(translationX: -joltOffset, y: 0)
            }
        }
        return animator
    }
}

// MARK: - Developer modes

#if DEBUG
extension PinScreenViewController {
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard presenter.flow.isLoginAuthentication else {
            return
        }
        switch motion {
        case .motionShake:
            devSupport.showDebugView(from: .pin)
        default:
            break
        }
    }
}
#endif
