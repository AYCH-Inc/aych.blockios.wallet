//
//  AssetAddressRepositoryMock.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

@testable import Blockchain

class AssetAddressRepositoryMock: AssetAddressFetching {
    
    let isReusable: Bool
    var alreadyUsedAddress: String?
    var addresses: [String]
    
    init(isReusable: Bool, addresses: [String], alreadyUsedAddress: String? = nil) {
        self.isReusable = isReusable
        self.addresses = addresses
        self.alreadyUsedAddress = alreadyUsedAddress
    }
    
    /// Checks usability of an asset address
    func checkUsability(of address: String, asset: AssetType) -> Single<AddressUsageStatus> {
        if isReusable {
            return .just(.unused(address: address))
        } else if address == alreadyUsedAddress {
            return .just(.used(address: address))
        } else {
            return .just(.unused(address: address))
        }
    }
    
    /// Return the candidate addresses by type and asset
    func addresses(by type: AssetAddressType, asset: AssetType) -> [AssetAddress] {
        var result: [AssetAddress] = []
        for address in addresses {
            switch asset {
            case .bitcoin:
                result += [BitcoinAddress(string: address)]
            case .bitcoinCash:
                result += [BitcoinCashAddress(string: address)]
            case .ethereum:
                result += [EthereumAddress(string: address)]
            case .pax:
                result += [PaxAddress(string: address)]
            case .stellar:
                result += [StellarAddress(string: address)]
            }
        }
        return result
    }
    
    /// Removes a given asset address according to type
    func remove(address: String, for assetType: AssetType, addressType: AssetAddressType) {
        guard let index = (addresses.index { $0 == address }) else {
            return
        }
        addresses.remove(at: index)
    }
}
