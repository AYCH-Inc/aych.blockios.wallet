//
//  EthereumKeyPairDeriver.swift
//  EthereumKit
//
//  Created by Jack on 05/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import web3swift
import RxSwift

public protocol EthereumKeyPairDeriverAPI: KeyPairDeriverAPI where Input == EthereumKeyDerivationInput, Pair == EthereumKeyPair {
    func derive(input: Input) -> Maybe<Pair>
}

public class AnyEthereumKeyPairDeriver: EthereumKeyPairDeriverAPI {
    public static let shared = AnyEthereumKeyPairDeriver()
    
    private let deriver: AnyKeyPairDeriver<EthereumKeyPair, EthereumKeyDerivationInput>
    
    // MARK: - Init
    
    public init<D: KeyPairDeriverAPI>(with deriver: D) where D.Input == EthereumKeyDerivationInput, D.Pair == EthereumKeyPair {
        self.deriver = AnyKeyPairDeriver<EthereumKeyPair, EthereumKeyDerivationInput>(deriver: deriver)
    }
    
    public func derive(input: EthereumKeyDerivationInput) -> Maybe<EthereumKeyPair> {
        return deriver.derive(input: input)
    }
}
