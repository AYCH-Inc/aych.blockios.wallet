//
//  KeyPairProviderAPI.swift
//  PlatformKit
//
//  Created by AlexM on 11/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol KeyPairProviderAPI {
    associatedtype Pair: KeyPair
    func loadKeyPair() -> Maybe<Pair>
}
