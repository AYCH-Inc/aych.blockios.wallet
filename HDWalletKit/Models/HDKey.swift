//
//  HDKey.swift
//  HDWalletKit
//
//  Created by Jack on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LibWally

internal struct ExtendedKey {
    let raw: Data
    let privateKey: UInt32
    let publicKey: UInt32
    let depth: UInt8
    let fingerprint: UInt32
    let childIndex: UInt32
    let chainCode: Data
}

internal struct HDKey {
    internal let extendedKey: ExtendedKey
    
    internal init(libWallyHDKey: LibWally.HDKey) {
        fatalError("Not yet implemented, LibWally.HDKey.ext_key is private")
    }
}
