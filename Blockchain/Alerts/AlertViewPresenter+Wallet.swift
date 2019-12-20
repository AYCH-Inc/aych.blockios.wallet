//
//  AlertViewPresenter+Wallet.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit
import PlatformKit

/// Extension for wallet-related alerts
extension AlertViewPresenter {

    /// Shows the site maintenance error message from `walletOptions` if any.
    ///
    /// - Parameter walletOptions: the WalletOptions
    func showMaintenanceError(from walletOptions: WalletOptions) {
        guard walletOptions.downForMaintenance else {
            Logger.shared.info("Not showing site maintenance alert. WalletOptions `downForMaintenance` flag is not set.")
            return
        }
        let message = walletOptions.mobileInfo?.message ?? LocalizationConstants.Errors.siteMaintenanceError
        AlertViewPresenter.shared.standardError(message: message)
    }
    
    /// Displays an alert to the user if the wallet object contains a value from `Wallet.getMobileMessage`.
    /// Otherwise, if there is no value, no such alert will be presented.
    @objc func showMobileNoticeIfNeeded() {
        guard let message = WalletManager.shared.wallet.getMobileMessage(), message.count > 0 else {
            return
        }

        standardNotify(message: message, title: LocalizationConstants.information)
    }
}
