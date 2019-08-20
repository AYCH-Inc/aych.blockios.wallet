//
//  StellarKeyPairDeriver.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import stellarsdk
import RxSwift

public class StellarKeyPairDeriver: KeyPairDeriverAPI {
    public typealias StellarWallet = stellarsdk.Wallet
    
    public func derive(input: StellarKeyDerivationInput) -> Result<StellarKeyPair, Error> {
        let keyPair: stellarsdk.KeyPair
        do {
            keyPair = try StellarWallet.createKeyPair(
                mnemonic: input.mnemonic,
                passphrase: input.passphrase,
                index: input.index
            )
        } catch {
            return .failure(error)
        }
        return .success(keyPair.toStellarKeyPair())
    }
}

private extension stellarsdk.KeyPair {
    func toStellarKeyPair() -> StellarKeyPair {
        return StellarKeyPair(accountID: publicKey.accountId, secret: secretSeed)
    }
}
