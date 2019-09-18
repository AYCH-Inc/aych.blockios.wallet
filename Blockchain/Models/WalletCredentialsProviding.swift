//
//  WalletCredentialsProviding.swift
//  Blockchain
//
//  Created by Daniel Huri on 09/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol WalletCredentialsProviding {
    var guid: String? { get }
    var sharedKey: String! { get }
}

extension Wallet: WalletCredentialsProviding {}
