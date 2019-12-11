//
//  AuthenticatorRepositoryAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 10/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol AuthenticatorRepositoryAPI: class {
    
    /// Streams the authenticator type
    var authenticatorType: Single<AuthenticatorType> { get }
    
    /// Sets the authenticator type
    func set(authenticatorType: AuthenticatorType) -> Completable
}
