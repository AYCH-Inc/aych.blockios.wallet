//
//  WalletLumensAccount.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// Model for a Lumens account stored in `WalletLumensMetadata`
struct WalletLumensAccount: Codable {
    let publicKey: String
    let label: String?
    let archived: Bool
}
