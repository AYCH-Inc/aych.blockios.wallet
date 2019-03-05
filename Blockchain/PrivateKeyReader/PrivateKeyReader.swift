//
//  PrivateKeyReader.swift
//  Blockchain
//
//  Created by Maurice A. on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc protocol PrivateKeyReaderDelegate: class {
    func didFinishScanning(_ privateKey: String, for address: AssetAddress?)
    @objc optional func didFinishScanningWithError(_ error: PrivateKeyReaderError)
}

// TODO: remove once AccountsAndAddresses and SendBitcoinViewController are migrated to Swift
@objc protocol LegacyPrivateKeyDelegate: class {
    func didFinishScanning(_ privateKey: String)
    @objc optional func didFinishScanningWithError(_ error: PrivateKeyReaderError)
}

@objc enum PrivateKeyReaderError: Int {
    case badMetadataObject
    case unknownKeyFormat
    case unsupportedPrivateKey
}
