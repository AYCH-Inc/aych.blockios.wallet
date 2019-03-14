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
    private var tiersViewController: KYCTiersViewController?
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if viewControllers.count > 0 {
            viewControllers.removeAll()
        }
        let disposable = KYCTiersViewController.tiersMetadata()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .do(onDispose: { LoadingViewPresenter.shared.hideBusyView() })
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                self.setupTiersController(model)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.setViewControllers([self.onboardingController], animated: false)
            })
        disposables.insertWithDiscardableResult(disposable)
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
    
    fileprivate func setupTiersController(_ model: KYCTiersPageModel) {
        tiersViewController = KYCTiersViewController.make(with: model)
        guard let controller = tiersViewController else { return }
        controller.selectedTier = { tier in
            KYCCoordinator.shared.startFrom(tier)
        }
        setViewControllers([controller], animated: false)
    }
    
    lazy var onboardingController: KYCOnboardingViewController = {
        let controller = KYCOnboardingViewController.makeFromStoryboard()
        controller.action = {
            KYCCoordinator.shared.start()
        }
        return controller
    }()
}
