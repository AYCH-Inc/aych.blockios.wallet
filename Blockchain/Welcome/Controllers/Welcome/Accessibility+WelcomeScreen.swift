//
//  Accessibility+WelcomeScreen.swift
//  Blockchain
//
//  Created by Daniel Huri on 14/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

extension Accessibility.Identifier {
    struct WelcomeScreen {
        static let prefix = "WelcomeScreen."
        struct Button {
            static let prefix = "\(WelcomeScreen.prefix)Button."
            static let createWallet = "\(prefix)createWallet"
            static let login = "\(prefix)login"
            static let recoverFunds = "\(prefix)recoverFunds"
        }
    }
}
