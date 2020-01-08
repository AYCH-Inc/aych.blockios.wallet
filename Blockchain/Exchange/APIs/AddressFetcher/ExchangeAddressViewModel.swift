//
//  ExchangeAddressViewModel.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// This is temporary as the `SendBitcoinViewController` will likely be deprecated soon.
@objc
final class ExchangeAddressViewModel: NSObject {
    
    // MARK: - Types

    // MARK: - Properties
    
    @objc let assetType: AssetType
    @objc var isExchangeLinked = false
    @objc var isTwoFactorEnabled = false
    @objc var address: String?
    
    // MARK: - Setup
    
    @objc
    init(legacyAssetType: LegacyAssetType) {
        self.assetType = AssetTypeLegacyHelper.convert(fromLegacy: legacyAssetType)
    }
    
    init(assetType: AssetType) {
        self.assetType = assetType
    }
    
    @objc var legacyAssetType: LegacyAssetType {
        return assetType.legacy
    }
}
