//
//  KeyPairDeriver.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol KeyPairDeriverAPI {
    associatedtype Pair: KeyPair
    associatedtype Input: KeyDerivationInput
    
    /// Derives a `KeyPair` given specific inputs (e.g. mnemonic + password)
    /// This action is deterministic (i.e. the same mnemonic + password combination will create the
    /// same key pair).
    ///
    /// - Parameter input: The specific inputs used to derive the key pair
    /// - Returns: A `Result` for the created `KeyPair`
    func derive(input: Input) -> Result<Pair, Error>
}

public final class AnyKeyPairDeriver<P: KeyPair, I: KeyDerivationInput>: KeyPairDeriverAPI {
    
    public typealias Deriver = (I) -> Result<P, Error>
    
    private let derivingClosure: Deriver
    
    public init<D: KeyPairDeriverAPI>(deriver: D) where D.Pair == P, D.Input == I {
        self.derivingClosure = deriver.derive
    }
    
    public func derive(input: I) -> Result<P, Error> {
        return derivingClosure(input)
    }
}
