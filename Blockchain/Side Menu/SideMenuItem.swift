//
//  SideMenuItem.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit
import PlatformUIKit

/// Model definition for an item that is presented in the side menu of the app.
enum SideMenuItem {
    typealias PulseAction = () -> Void
    typealias Title = String
    case accountsAndAddresses
    case backup
    case buyBitcoin(PulseAction?)
    case logout
    case airdrops
    case settings
    case support
    case upgrade
    case webLogin
    case lockbox
    case exchange
}

extension SideMenuItem {
    
    var analyticsEvent: AnalyticsEvents.SideMenu {
        switch self {
        case .accountsAndAddresses:
            return .sideNavAccountsAndAddresses
        case .backup:
            return .sideNavBackup
        case .buyBitcoin:
            return .sideNavBuyBitcoin
        case .logout:
            return .sideNavLogout
        case .settings:
            return .sideNavSettings
        case .airdrops:
            return .sideNavAirdropCenter
        case .support:
            return .sideNavSupport
        case .upgrade:
            return .sideNavUpgrade
        case .webLogin:
            return .sideNavWebLogin
        case .lockbox:
            return .sideNavLockbox
        case .exchange:
            return .sideNavExchange
        }
    }
    
    var title: String {
        switch self {
        case .accountsAndAddresses:
            return LocalizationConstants.SideMenu.addresses
        case .backup:
            return LocalizationConstants.SideMenu.backupFunds
        case .buyBitcoin:
            return LocalizationConstants.SideMenu.buySellBitcoin
        case .logout:
            return LocalizationConstants.SideMenu.logout
        case .settings:
            return LocalizationConstants.SideMenu.settings
        case .airdrops:
            return LocalizationConstants.SideMenu.airdrops
        case .support:
            return LocalizationConstants.SideMenu.support
        case .upgrade:
            return LocalizationConstants.LegacyUpgrade.upgrade
        case .webLogin:
            return LocalizationConstants.SideMenu.loginToWebWallet
        case .lockbox:
            return LocalizationConstants.SideMenu.lockbox
        case .exchange:
            return LocalizationConstants.SideMenu.exchange
        }
    }

    private var imageName: String {
        switch self {
        case .accountsAndAddresses:
            return "menu-icon-addresses"
        case .backup:
            return "menu-icon-backup"
        case .buyBitcoin:
            return "menu-icon-buy"
        case .logout:
            return "menu-icon-logout"
        case .airdrops:
            return "menu-icon-airdrop"
        case .settings:
            return "menu-icon-settings"
        case .support:
            return "menu-icon-help"
        case .upgrade:
            return "menu-icon-upgrade"
        case .webLogin:
            return "menu-icon-pair-web-wallet"
        case .lockbox:
            return "menu-icon-lockbox"
        case .exchange:
            return "menu-icon-exchange"
        }
    }

    var image: UIImage {
        return UIImage(named: imageName)!
    }
    
    var isNew: Bool {
        switch self {
        case .accountsAndAddresses,
             .backup,
             .buyBitcoin,
             .logout,
             .settings,
             .support,
             .airdrops,
             .upgrade,
             .lockbox,
             .webLogin:
            return false
        case .exchange:
            return true
        }
    }
}
