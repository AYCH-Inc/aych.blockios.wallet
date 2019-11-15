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
        
    public enum PollError: Error {
        
        /// Cancellation error
        case cancel
        
        /// Session token is missing
        case missingSessionToken
        
        /// Instance of self was deallocated
        case unretainedSelf
    }
    
    /// Steams a `completed` event once, upon successful authorization.
    /// Keeps polling until completion event is received
    public var authorize: Completable {
        return authorizeEmail()
            .asCompletable()
    }
    
    private let lock = NSRecursiveLock()
    private var _isCancelled = false
    private var isCancelled: Bool {
        set {
            lock.lock()
            defer { lock.unlock() }
            self._isCancelled = newValue
        }
        get {
            lock.lock()
            defer { lock.unlock() }
            return _isCancelled
        }
    }
    
    // MARK: - Injected
    
    private let guidClient: GuidClientAPI
        
    // MARK: - Setup
    
    public init(guidClient: GuidClientAPI) {
        self.guidClient = guidClient
    }
    
    /// Cancels the authorization by sending interrupt to stop polling
    public func cancel() {
        isCancelled = true
    }
    
    // MARK: - Accessors
    
    private func authorizeEmail() -> Single<Void> {
        return guidClient.guid // Fetch the guid
            .mapToVoid() // Map to void as we just want to verify it could be retrieved
            /// Any error should be caught and unless the request was cancelled or
            /// session token was missing, just keep polling until the guid is retrieved
            .catchError { [weak self] error -> Single<Void> in
                guard let self = self else { throw PollError.unretainedSelf }
                /// In case the session token is missing, don't continue since the `sessionToken`
                /// is essential to form the request
                switch error {
                case GuidClient.FetchError.missingSessionToken:
                    self.cancel()
                    throw PollError.missingSessionToken
                default:
                    break
                }
                guard !self.isCancelled else { throw PollError.cancel }
                return Single<Int>
                    .timer(
                        .seconds(2),
                        scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
                    )
                    .flatMap(weak: self) { (self, _) -> Single<Void> in
                        return self.authorizeEmail()
                    }
            }
    }
}
