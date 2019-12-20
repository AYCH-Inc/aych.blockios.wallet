//
//  PinRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 09/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import ToolKit

/// PIN creation / changing / authentication. Responsible for routing screens during flow.
final class PinRouter: NSObject {
    
    // MARK: - Properties
    
    /// The origin of the pin flow
    let flow: PinRouting.Flow
    
    /// Returns `true` in case login authentication is currently being displayed
    var isDisplayingLoginAuthentication: Bool {
        return isBeingDisplayed && flow.isLoginAuthentication
    }
    
    /// Is being displayed right now
    private(set) var isBeingDisplayed = false
    
    /// Wrap up the current flow and move to the next
    private let completion: PinRouting.RoutingType.Forward?
    
    /// Reference to previous view controller
    private var previousRootViewController: UIViewController!

    /// Weakly references the pin navigation controller as we don't want to keep it while it's not currently presented
    private weak var navigationController: UINavigationController!
    
    /// A recorder for errors
    private let recorder: Recording
    
    /// Swipe to receive configuration
    private let swipeToReceiveConfig: SwipeToReceiveConfiguring
    
    // MARK: - Setup
    
    init(flow: PinRouting.Flow,
         swipeToReceiveConfig: SwipeToReceiveConfiguring = BlockchainSettings.App.shared,
         recorder: Recording = CrashlyticsRecorder(),
         completion: PinRouting.RoutingType.Forward? = nil) {
        self.flow = flow
        self.swipeToReceiveConfig = swipeToReceiveConfig
        self.recorder = recorder
        self.completion = completion
        super.init()
    }

    // MARK: - API
    
    /// Executes the pin flow according to the `flow` value provided during initialization
    func execute() {
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            guard !self.isBeingDisplayed else { return }
            
            self.isBeingDisplayed = true
            switch self.flow {
            case .create:
                self.create()
            case .change:
                self.change()
            case .authenticate(from: let origin, logoutRouting: _):
                self.authenticate(from: origin)
            case .enableBiometrics: // Here the origin is `.foreground`
                self.authenticate(from: self.flow.origin)
            }
        }
    }
    
    /// Cleanup immediately any currently running pin flow
    func cleanup() {
        DispatchQueue.main.async { [weak self] in
            self?.finish(animated: false, completedSuccessfully: false)
        }
    }
}

// MARK: - Private Logic

extension PinRouter {
    
    // MARK: - Entry points of pin flow
    
    /// Invokes authentication using pin code
    private func authenticate(from origin: PinRouting.Flow.Origin) {
        let forwardRouting: PinRouting.RoutingType.Forward = { [weak self] input in
            self?.finish(completionInput: input)
        }
        let useCase: PinScreenUseCase
        switch self.flow {
        case .authenticate:
            useCase = .authenticateOnLogin
        case .enableBiometrics:
            useCase = .authenticateBeforeEnablingBiometrics
        default: // Shouldn't arrive here
            return
        }
        
        // Add cleanup to logout
        let flow = PinRouting.Flow.authenticate(from: origin) { [weak self] in
            self?.cleanup()
            self?.flow.logoutRouting?()
        }
        
        let presenter = PinScreenPresenter(useCase: useCase,
                                           flow: flow,
                                           forwardRouting: forwardRouting)
        let pinViewController = PinScreenViewController(using: presenter)
        if useCase.isAuthenticateOnLogin {
            authenticateOnLogin(using: pinViewController)
        } else {
            present(viewController: pinViewController)
        }
    }
    
    /// Leads to authentication flow on logic.
    /// - parameter pinViewController: Pin view controller to be the first screen
    private func authenticateOnLogin(using pinViewController: UIViewController) {
        let pinInput = LoginContainerViewController.Input.viewController(pinViewController)
        let addressInputs: [LoginContainerViewController.Input]
        if swipeToReceiveConfig.swipeToReceiveEnabled {
            addressInputs = AssetType.all.map { asset -> LoginContainerViewController.Input in
                let interactor = AddressInteractor(asset: asset, addressType: .swipeToReceive)
                let presenter = AddressPresenter(interactor: interactor)
                let viewController = AddressViewController(using: presenter)
                return .viewController(viewController)
            }
        } else {
            addressInputs = []
        }

        let containerViewController = LoginContainerViewController(using: [pinInput] + addressInputs)
        present(viewController: containerViewController)
    }
    
    /// Invokes a PIN change flow in which a user has to verify the old PIN -> select a new PIN -> create a new PIN
    private func change() {
        let backwardRouting: PinRouting.RoutingType.Backward = { [weak self] in
            self?.finish()
        }
        let forwardRouting: PinRouting.RoutingType.Forward = { [weak self] input in
            self?.select(previousPin: input.pin)
        }
        
        // Add cleanup to logout
        let flow = PinRouting.Flow.change(parent: UnretainedContentBox(self.flow.parent)) { [weak self] in
            self?.cleanup()
            self?.flow.logoutRouting?()
        }
        
        let presenter = PinScreenPresenter(useCase: .authenticateBeforeChanging,
                                           flow: flow,
                                           backwardRouting: backwardRouting,
                                           forwardRouting: forwardRouting)
        let viewController = PinScreenViewController(using: presenter)
        present(viewController: viewController)
    }
    
    /// Invokes a PIN creation flow in which a user has to select a new PIN -> create a new PIN
    private func create() {
        select()
    }
    
    /// Selection - Once a new pin needs to be created (change / creation), the user is required to select it.
    private func select(previousPin: Pin? = nil) {
        let useCase = PinScreenUseCase.select(previousPin: previousPin)
        let backwardRouting: PinRouting.RoutingType.Backward = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        let forwardRouting: PinRouting.RoutingType.Forward = { [weak self] input in
            self?.create(pin: input.pin!)
        }
        let presenter = PinScreenPresenter(useCase: useCase,
                                           flow: flow,
                                           backwardRouting: backwardRouting,
                                           forwardRouting: forwardRouting)
        let viewController = PinScreenViewController(using: presenter)
        present(viewController: viewController)
    }
    
    /// Creation - after the user has selected a new PIN, he is required to repeat it.
    private func create(pin: Pin) {
        let useCase = PinScreenUseCase.create(firstPin: pin)
        let backwardRouting: PinRouting.RoutingType.Backward = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        let forwardRouting: PinRouting.RoutingType.Forward = { [weak self] pin in
            self?.finish(performsCompletionAfterDismissal: false)
        }
        let presenter = PinScreenPresenter(useCase: useCase,
                                           flow: flow,
                                           backwardRouting: backwardRouting,
                                           forwardRouting: forwardRouting)
        let viewController = PinScreenViewController(using: presenter)
        present(viewController: viewController)
    }
    
    /// Handle the display of a new view controller
    private func present(viewController: UIViewController) {
        if let navigationController = navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.delegate = self
            switch flow.origin {
            case .background:
                let window = UIApplication.shared.keyWindow!
                previousRootViewController = window.rootViewController!
                window.rootViewController = navigationController
            case .foreground(parent: let boxedParent):
                if let parent = boxedParent.value {
                    navigationController.modalPresentationStyle = .fullScreen
                    parent.present(navigationController, animated: true)
                } else {
                    recorder.error("Parent view controller must not be `nil` for foreground authentication")
                }
            }
            self.navigationController = navigationController
        }
    }
    
    /// Cleanup the flow and calls completion handler
    private func finish(animated: Bool = true,
                        performsCompletionAfterDismissal: Bool = true,
                        completedSuccessfully: Bool = true,
                        completionInput: PinRouting.RoutingType.Input = .none) {        
        // Concentrate any cleaup logic here
        let cleanup = { [weak self] in
            guard let self = self else { return }
            self.navigationController = nil
            self.previousRootViewController = nil
            self.isBeingDisplayed = false
            if completedSuccessfully && performsCompletionAfterDismissal {
                self.completion?(completionInput)
            }
        }

        // Dismiss the pin flow
        switch flow.origin {
        case .foreground:
            guard let controller = navigationController else {
                // The contorller MUST be allocated at that point. report non-fatal in case something goes wrong
                recorder.error(PinRouting.FlowError.navigationControllerIsNotInitialized)
                return
            }
            if completedSuccessfully && !performsCompletionAfterDismissal {
                completion?(completionInput)
            }
            controller.dismiss(animated: animated, completion: cleanup)
        case .background:
            UIApplication.shared.keyWindow!.rootViewController = previousRootViewController
            cleanup()
        }
    }
}

// MARK: - UINavigationControllerDelegate (Screen routing animation)

extension PinRouter: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = ScreenTransitioningAnimator.TransitionType.translate(from: operation, duration: 0.4)
        return ScreenTransitioningAnimator(transition: transition)
    }
}
