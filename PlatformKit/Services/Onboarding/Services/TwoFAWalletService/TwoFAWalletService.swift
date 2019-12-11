//
//  TwoFAWalletService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 21/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class TwoFAWalletService: TwoFAWalletServiceAPI {
    
    /// Potential errors that may arise during 2FA initialization
    public enum ServiceError: Error {
        
        /// Cannot send 2FA code because the code is empty
        case missingCode
        
        /// 2FA OTP code is wrong
        case wrongCode(attemptsLeft: Int)
        
        /// The payload returned from the backend is empty
        case missingPayload
        
        case accountLocked
    }
    
    // MARK: - Properties
    
    private let client: TwoFAWalletClientAPI
    private let repository: WalletRepositoryAPI
    
    public init(client: TwoFAWalletClientAPI, repository: WalletRepositoryAPI) {
        self.client = client
        self.repository = repository
    }
    
    public func send(code: String) -> Completable {
        // Trim whitespaces before verifying and sending
        let code = code.trimmingWhitespaces
        
        /// Verify the code is not empty to save network call
        guard !code.isEmpty else {
            return .error(ServiceError.missingCode)
        }
        
        /// 1. Zip guid and session-token
        /// 2. Verify they have values
        /// 3. Send payload request using client
        /// 4. Validate the payload (by checking it is not empty) and cache it
        /// 5. Convert to `Completable`
        /// *. Errors along the way should be caught and mapped
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
            .flatMap(weak: self) { (self, credentials) -> Single<WalletPayload> in
                return self.client.payload(guid: credentials.guid, sessionToken: credentials.sessionToken, code: code)
            }
            .flatMapCompletable(weak: self) { (self, response) -> Completable in
                guard let rawPayload = response.stringRepresentation, !rawPayload.isEmpty else {
                    throw ServiceError.missingPayload
                }
                return self.repository.set(payload: rawPayload)
            }
            .catchError { error -> Completable in
                switch error {
                case TwoFAWalletClient.ClientError.wrongCode(attemptsLeft: let attempts):
                    throw ServiceError.wrongCode(attemptsLeft: attempts)
                case TwoFAWalletClient.ClientError.accountLocked:
                    throw ServiceError.accountLocked
                default:
                    throw error
                }
            }
    }
}
