//
//  EmailAuthorizationService.swift
//  Blockchain
//
//  Created by Daniel Huri on 13/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public final class EmailAuthorizationService {
    
    // MARK: - Types
        
    public enum ServiceError: Error {
                
        /// Session token is missing
        case missingSessionToken
        
        /// Instance of self was deallocated
        case unretainedSelf
        
        /// Authorization is already active
        case authorizationAlreadyActive
        
        /// Cancellation error
        case authorizationCancelled
    }
    
    /// Steams a `completed` event once, upon successful authorization.
    /// Keeps polling until completion event is received
    public var authorize: Completable {
        return authorizeEmail()
            .asCompletable()
    }
    
    private let lock = NSRecursiveLock()
    private var _isActive = false
    private var isActive: Bool {
        set {
            lock.lock()
            defer { lock.unlock() }
            self._isActive = newValue
        }
        get {
            lock.lock()
            defer { lock.unlock() }
            return _isActive
        }
    }
    
    // MARK: - Injected
    
    private let guidService: GuidServiceAPI
        
    // MARK: - Setup
    
    public init(guidService: GuidServiceAPI) {
        self.guidService = guidService
    }
    
    /// Cancels the authorization by sending interrupt to stop polling
    public func cancel() {
        isActive = false
    }
    
    // MARK: - Accessors
    
    private func authorizeEmail() -> Single<Void> {
        guard !isActive else {
            return .error(ServiceError.authorizationAlreadyActive)
        }
        isActive = true
        return guidService.guid // Fetch the guid
            .mapToVoid() // Map to void as we just want to verify it could be retrieved
            /// Any error should be caught and unless the request was cancelled or
            /// session token was missing, just keep polling until the guid is retrieved
            .catchError { [weak self] error -> Single<Void> in
                guard let self = self else { throw ServiceError.unretainedSelf }
                /// In case the session token is missing, don't continue since the `sessionToken`
                /// is essential to form the request
                switch error {
                case GuidService.FetchError.missingSessionToken:
                    self.cancel()
                    throw ServiceError.missingSessionToken
                default:
                    break
                }
                guard self.isActive else {
                    throw ServiceError.authorizationCancelled
                }
                return Single<Int>
                    .timer(
                        .seconds(2),
                        scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
                    )
                    .flatMap(weak: self) { (self, _) -> Single<Void> in
                        self.isActive = false
                        return self.authorizeEmail()
                    }
            }
    }
}
