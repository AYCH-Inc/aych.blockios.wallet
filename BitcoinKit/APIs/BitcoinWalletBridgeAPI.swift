//
//  BitcoinWalletBridgeAPI.swift
//  BitcoinKit
//
//  Created by kevinwu on 2/5/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public protocol BitcoinWalletBridgeAPI: class {
    /// If an imported address or HD account is active, it means that it is not archived.

    // MARK: - HD Accounts

    func hdAccounts() -> Single<[BitcoinHDAssetAccount]>

    func balance(of HDAccounts: [BitcoinHDAssetAccount]) -> Single<CryptoValue>

    func transactions(for HDAccounts: [BitcoinHDAssetAccount]) -> Single<[BitcoinTransaction]>

    // MARK: - Imported Addresses

    func importedAddresses() -> Single<[BitcoinAssetAddress]>

    func balance(of importedAddresses: [BitcoinAssetAddress]) -> Single<CryptoValue>

    func transactions(for importedAddresses: [BitcoinAssetAddress]) -> Single<[BitcoinTransaction]>

    // TODO: add archiving/unarchiving support and add Archivable protocol
}
