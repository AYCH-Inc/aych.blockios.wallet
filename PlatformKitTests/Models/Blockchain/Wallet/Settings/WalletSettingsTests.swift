//
//  WalletSettingsTests.swift
//  PlatformKitTests
//
//  Created by Chris Arriola on 11/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import XCTest

class WalletSettingsTests: XCTestCase {
    // swiftlint:disable:next function_body_length
    func testWalletSettingsDecoding() {
        let guid = "test_guid"
        let currency = "USD"
        let authType = AuthenticatorType.standard
        let jsonString = """
        {
            "btc_currency": "BTC",
            "notifications_type": [],
            "language": "en",
            "notifications_on": 0,
            "ip_lock_on": 0,
            "dial_code": "1",
            "block_tor_ips": 0,
            "currency": "\(currency)",
            "notifications_confirmations": 0,
            "auto_email_backup": 0,
            "never_save_auth_type": 0,
            "email": "testemail@something.com",
            "sms_verified": 0,
            "is_api_access_enabled": 0,
            "auth_type": \(authType.rawValue),
            "my_ip": "10.133.0.78",
            "email_verified": 0,
            "languages": {
                "de": "German",
                "no": "Norwegian",
                "hi": "Hindi",
                "fi": "Finnish",
                "ru": "Russian",
                "pt": "Portuguese",
                "bg": "Bulgarian",
                "fr": "French",
                "hu": "Hungarian",
                "zh-cn": "Chinese_Simplified",
                "sl": "Slovenian",
                "id": "Indonesian",
                "sv": "Swedish",
                "ko": "Korean",
                "zh-tw": "Chinese_Traditional",
                "ms": "Malay",
                "el": "Greek",
                "en": "Language",
                "it": "Italian",
                "es": "Spanish",
                "vi": "Vietnamese",
                "th": "Thai",
                "ja": "Japanese",
                "pl": "Polish",
                "da": "Danish",
                "ro": "Romanian",
                "nl": "Dutch",
                "tr": "Turkish"
            },
            "invited": {
                "sfoxBuyV4": true,
                "sfoxSell": true,
                "lockbox": true,
                "sfoxBuy": false,
                "kyc": true,
                "coinify": true,
                "coinifySell": true,
                "coinifyBuy": true,
                "sfox": true,
                "coinifyRecurringBuy": true,
                "unocoin": true
            },
            "country_code": "US",
            "unsubscribed": false,
            "logging_level": 0,
            "guid": "\(guid)",
            "btc_currencies": {
                "BTC": "Bitcoin",
                "UBC": "Bits (uBTC)",
                "MBC": "MilliBit (mBTC)"
            },
            "currencies": {
                "CHF": "Swiss Franc",
                "HKD": "Hong Kong Dollar",
                "TWD": "New Taiwan dollar",
                "ISK": "Icelandic Króna",
                "EUR": "Euro",
                "DKK": "Danish Krone",
                "CLP": "Chilean Peso",
                "CAD": "Canadian Dollar",
                "USD": "U.S. dollar",
                "INR": "Indian Rupee",
                "CNY": "Chinese yuan",
                "THB": "Thai baht",
                "AUD": "Australian Dollar",
                "KRW": "South Korean Won",
                "SGD": "Singapore Dollar",
                "JPY": "Japanese Yen",
                "PLN": "Polish Zloty",
                "GBP": "Great British Pound",
                "SEK": "Swedish Krona",
                "NZD": "New Zealand Dollar",
                "BRL": "Brazil Real",
                "RUB": "Russian Ruble"
            }
        }
        """
        let json = jsonString.data(using: .utf8)!
        let walletSettings = try? JSONDecoder().decode(WalletSettings.self, from: json)
        XCTAssertNotNil(walletSettings)
        XCTAssertEqual(guid, walletSettings!.guid)
        XCTAssertEqual(currency, walletSettings!.currency)
        XCTAssertEqual(authType, walletSettings!.authenticationTwoFactorType)
    }
}
