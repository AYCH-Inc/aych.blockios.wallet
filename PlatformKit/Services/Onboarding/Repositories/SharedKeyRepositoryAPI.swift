//
//  SharedKeyRepositoryAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 03/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SharedKeyRepositoryAPI: class {
    /// Streams `Bool` indicating whether the shared key is currently cached in the repo
    var hasSharedKey: Single<Bool> { get }
    
    /// Streams the cached shared key or `nil` if it is not cached
    var sharedKey: Single<String?> { get }
    
    /// Sets the shared key
    func set(sharedKey: String) -> Completable
}

public extension SharedKeyRepositoryAPI {
    var hasSharedKey: Single<Bool> {
        return sharedKey
            .map { sharedKey in
                guard let sharedKey = sharedKey else { return false }
                return !sharedKey.isEmpty
            }
    }
}
