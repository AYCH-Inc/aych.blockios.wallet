//
//  KeyDerivationInput.swift
//  PlatformKit
//
//  Created by Jack on 08/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol KeyDerivationInput {
    /// The mnemonic phrase used to derive the key pair
    var mnemonic: String { get }
}
