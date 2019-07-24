//
//  SideMenuPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Protocol definition for a view that displays a list of
/// SideMenuItem objects.
protocol SideMenuView: class {
    func setMenu(items: [SideMenuItem])
}

/// Presenter for the side menu of the app. This presenter
/// will handle the logic as to what side menu items should be
/// presented in the SideMenuView.
class SideMenuPresenter {

    private weak var view: SideMenuView?
    
    // MARK: - Services
    
    private let wallet: Wallet
    private let walletService: WalletService
    private let pitConfiguration: AppFeatureConfiguration
    
    private var disposable: Disposable?

    init(
        view: SideMenuView,
        wallet: Wallet = WalletManager.shared.wallet,
        walletService: WalletService = WalletService.shared,
        pitConfiguration: AppFeatureConfiguration = AppFeatureConfigurator.shared.configuration(for: .pitLinking)
    ) {
        self.view = view
        self.wallet = wallet
        self.walletService = walletService
        self.pitConfiguration = pitConfiguration
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    func loadSideMenu() {
        setMenuItems()
    }

    private func setMenuItems() {
        var items: [SideMenuItem] = [.accountsAndAddresses]
        
        if wallet.isLockboxEnabled() {
            items.append(.lockbox)
        }
        
        if wallet.didUpgradeToHd() {
            items.append(.backup)
        } else {
            items.append(.upgrade)
        }
        
        if wallet.isBuyEnabled() {
            items.append(.buyBitcoin)
        }
        
        items += [.support, .settings]
        
        if pitConfiguration.isEnabled {
            items.append(.pit)
        }
        
        view?.setMenu(items: items)
    }
}
