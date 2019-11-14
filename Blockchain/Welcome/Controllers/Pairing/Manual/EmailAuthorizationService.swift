//
//  EmailAuthorizationService.swift
//  Blockchain
//
//  Created by Daniel Huri on 13/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay

protocol EmailAuthorizationServiceAPI: class {
    var authorize: Completable { get }
}

final class EmailAuthorizationService: EmailAuthorizationServiceAPI {
        
    enum PollError: Error {
        case cancel
        case unretainedSelf
    }
    
    var authorize: Completable {
        return fullyAuthorize()
            .asCompletable()
    }
    
    private let lock = NSRecursiveLock()
        
    private var _isCancelled = false
    var isCancelled: Bool {
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
    
    private let wallet: Wallet
    private let sessionGuidService: SessionGuidServiceAPI
    private let sessionTokenService = SessionTokenService()
    private let walletService = GetWalletService()
    
    // MARK: - Setup
    
    init(wallet: Wallet = WalletManager.shared.wallet,
         sessionGuidService: SessionGuidServiceAPI = SessionGuidService()) {
        self.wallet = wallet
        self.sessionGuidService = sessionGuidService
    }
    
    /// Completable that waits for email authorization before completing
    private func fullyAuthorize() -> Single<Void> {
        return walletService.wallet(using: wallet.guid!, token: wallet.sessionToken).flatMap(weak: self) { (self, result) -> Single<Void> in
            switch result {
            case .failure(let response) where response.authorization_required:
                return self.authorizeEmail()
            default:
                return .just(())
            }
        }
    }
    
    private func authorizeEmail() -> Single<Void> {
        retrieveSessionGuid()
            .catchError { error -> Single<Void> in
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
    
    private func retrieveSessionGuid() -> Single<Void> {
        return self.sessionGuidService
            .sessionGuid(using: self.wallet.sessionToken)
            .mapToVoid()
    }
}
