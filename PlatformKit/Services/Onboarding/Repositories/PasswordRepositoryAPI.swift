//
//  PasswordRepositoryAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 04/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol PasswordRepositoryAPI: class {
    
    /// Streams `Bool` indicating whether a password is currently cached in the repo
    var hasPassword: Single<Bool> { get }
    
    /// Streams the cached password or `nil` if it is not cached
    var password: Single<String?> { get }
    
    /// Sets the password
    func set(password: String) -> Completable
}

public extension PasswordRepositoryAPI {
    var hasPassword: Single<Bool> {
        return password
            .map { password in
                guard let password = password else { return false }
                return !password.isEmpty
            }
    }
}
