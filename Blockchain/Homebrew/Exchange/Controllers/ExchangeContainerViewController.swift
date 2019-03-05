//
//  ExchangeContainerViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 2/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit
import SafariServices
import RxSwift

class ExchangeContainerViewController: BaseNavigationController {
    
    // MARK: Private Properties
    
    private let disposables = CompositeDisposable()
    private let coordinator: ExchangeCoordinator = ExchangeCoordinator.shared
    private let wallet: Wallet = WalletManager.shared.wallet
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupNotifications()
        setupExchangeIfPermitted()
    }
    
    @objc func showExchange() {
        LoadingViewPresenter.shared.hideBusyView()
        guard viewControllers.filter({ $0 is ExchangeCreateViewController == true }).count == 0 else { return }
        viewControllers.removeAll()
        let storyboard = UIStoryboard(
            name: String(describing: ExchangeCreateViewController.self),
            bundle: Bundle(for: type(of: self))
        )
        guard let rootViewController = storyboard.instantiateInitialViewController() else { return }
        setViewControllers([rootViewController], animated: false)
    }
    
    @objc func showWelcome() {
        viewControllers.removeAll()
        LoadingViewPresenter.shared.hideBusyView()
        setViewControllers([onboardingController], animated: false)
    }
    
    fileprivate func setupNotifications() {
        NotificationCenter.when(Constants.NotificationKeys.kycComplete) { [weak self] _ in
            guard let this = self else { return }
            this.setupExchangeIfPermitted()
        }
    }
    
    fileprivate func setupExchangeIfPermitted() {
        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.loading)
        let disposable = coordinator.canSwap()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] canSwap in
                guard let this = self else { return }
                switch canSwap {
                case true:
                    this.coordinator.initXlmAccountIfNeeded {
                        if this.wallet.hasEthAccount() == false {
                            this.coordinator.createEthAccountForExchange()
                        } else {
                            this.showExchange()
                        }
                    }
                case false:
                    this.showWelcome()
                }
                }, onError: { error in
                    // TICKET: [IOS-1997] Handle failure state for `canSwap`
                    Logger.shared.error("Failed to get user: \(error.localizedDescription)")
            })
        disposables.insertWithDiscardableResult(disposable)
    }
    
    fileprivate func startKYC() {
        KYCCoordinator.shared.start()
    }
    
    lazy var onboardingController: KYCOnboardingViewController = {
        let controller = KYCOnboardingViewController.makeFromStoryboard()
        controller.action = {
            self.startKYC()
        }
        return controller
    }()
}
