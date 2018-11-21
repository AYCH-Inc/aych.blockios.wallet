//
//  WalletSettingsApiMethod.swift
//  PlatformKit
//
//  Created by Chris Arriola on 11/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates the API methods supported by the wallet settings endpoint.
public enum WalletSettingsApiMethod: String {
    case getInfo = "get-info"
    case verifyEmail = "verify-email"
    case verifySms = "verify-sms"
    case updateNotificationType = "update-notifications-type"
    case updateNotificationOn = "update-notifications-on"
    case updateSms = "update-sms"
    case updateEmail = "update-email"
    case updateBtcCurrency = "update-btc-currency"
    case updateCurrency = "update-currency"
    case updatePasswordHint  = "update-password-hint1"
    case updateAuthType = "update-auth-type"
    case updateBlockTorIps = "update-block-tor-ips"
    case updateLastTxTime = "update-last-tx-time"
}
