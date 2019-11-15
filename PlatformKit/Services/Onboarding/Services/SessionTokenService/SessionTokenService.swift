//
//  SessionTokenService.swift
//  Blockchain
//
//  Created by Daniel Huri on 12/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SessionTokenService: SessionTokenServiceAPI {
        
    // MARK: - Injected
    
    private let client: SessionTokenClientAPI
    private let repository: SessionTokenRepositoryAPI
    
    // MARK: - Setup
    
    public init(client: SessionTokenClientAPI = SessionTokenClient(), repository: SessionTokenRepositoryAPI) {
        self.client = client
        self.repository = repository
    }
    
    /// Requests a session token for the wallet, if not available already
    /// and assign it to the repository.
    public func setupSessionToken() -> Completable {
        guard !repository.hasSessionToken else { return .empty() }
        return client.token
            .do(onSuccess: { [weak self] token in
                self?.repository.sessionToken = token
            })
            .asCompletable()
    }
}
