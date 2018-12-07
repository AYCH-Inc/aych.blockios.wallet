//
//  WalletAccount.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol WalletAccount {
    var index: Int { get }
    var publicKey: String { get }
    var label: String? { get }
    var archived: Bool { get }
}
