//
//  GuidService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 15/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class GuidService: GuidServiceAPI {
    
    // MARK: - Types
    
    public enum FetchError: Error {
        case missingSessionToken
    }
    
    // MARK: - Properties
    
    /// Fetches the `GUID`
    public var guid: Single<String> {
        guard let token = sessionTokenRepository.sessionToken else {
            return .error(FetchError.missingSessionToken)
        }
        return client.guid(by: token)
    }
    
    private let sessionTokenRepository: SessionTokenRepositoryAPI
    private let client: GuidClientAPI
    
    // MARK: - Setup
    
    public init(sessionTokenRepository: SessionTokenRepositoryAPI, client: GuidClientAPI) {
        self.sessionTokenRepository = sessionTokenRepository
        self.client = client
    }
}
