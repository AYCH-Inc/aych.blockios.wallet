//
//  BitcoinQRMetadataFactory.swift
//  BitcoinKit
//
//  Created by Jack on 05/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public class BitcoinQRMetadataFactory: CryptoAssetQRMetadataFactory {
    public typealias Metadata = BitcoinQRMetadata
    
    public typealias Account = BitcoinWalletAccount
    
    public init() {}
    
    public func create(from account: Account) -> Metadata? {
        return BitcoinQRMetadata(address: account.publicKey, amount: nil)
    }
}
