//
//  SMSService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 21/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SMSService: SMSServiceAPI {
    
    // MARK: - Properties
    
    private let client: SMSClientAPI
    private let repository: WalletRepositoryAPI
    
    public init(client: SMSClientAPI, repository: WalletRepositoryAPI) {
        self.repository = repository
        self.client = client
    }
    
    // MARK: - API
    
    public func request() -> Completable {
        return Single
            .zip(repository.guid, repository.sessionToken)
            .map(weak: self) { (self, credentials) -> (guid: String, sessionToken: String) in
                guard let guid = credentials.0 else {
                    throw MissingCredentialsError.guid
                }
                guard let sessionToken = credentials.1 else {
                    throw MissingCredentialsError.sessionToken
                }
                return (guid, sessionToken)
            }
            .flatMapCompletable(weak: self) { (self, credentials) -> Completable in
                return self.client.requestOTP(
                    sessionToken: credentials.sessionToken,
                    guid: credentials.guid
                )
            }
    }
}
