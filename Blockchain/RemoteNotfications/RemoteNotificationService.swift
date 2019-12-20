//
//  RemoteNotificationService.swift
//  Blockchain
//
//  Created by Daniel Huri on 09/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRelay
import ToolKit
import PlatformKit

/// A service that coordinates
final class RemoteNotificationService: RemoteNotificationServicing {
    
    // MARK: - ServiceError
    
    private enum ServiceError: Error {
        case unauthorizedRemoteNotificationsPermission
    }
    
    // MARK: - RemoteNotificationServicing (services)
    
    let relay: RemoteNotificationEmitting
    let authorizer: RemoteNotificationAuthorizing
    
    // MARK: - Privately used services
    
    private let externalService: ExternalNotificationProviding
    private let networkService: RemoteNotificationNetworkServicing
    private let credentialsProvider: WalletCredentialsProviding
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(authorizer: RemoteNotificationAuthorizing = RemoteNotificationAuthorizer(),
         relay: RemoteNotificationEmitting = RemoteNotificationRelay(),
         externalService: ExternalNotificationProviding = ExternalNotificationServiceProvider(),
         networkService: RemoteNotificationNetworkServicing = RemoteNotificationNetworkService(),
         credentialsProvider: WalletCredentialsProviding = WalletManager.shared.legacyRepository) {
        self.authorizer = authorizer
        self.relay = relay
        self.externalService = externalService
        self.networkService = networkService
        self.credentialsProvider = credentialsProvider
    }
}

// MARK: - RemoteNotificationTokenSending

extension RemoteNotificationService: RemoteNotificationTokenSending {
    
    /// Sends the token. Only if remote notification permission was pre-authorized.
    /// Typically called after the user has identified himself with his PIN since the
    /// user credentials are known at that time
    func sendTokenIfNeeded() -> Single<Void> {
        return authorizer.isAuthorized
            .filter { isAuthorized in
                guard isAuthorized else {
                    throw ServiceError.unauthorizedRemoteNotificationsPermission
                }
                return true
            }
            .flatMap(weak: self) { (self, _) -> Single<String> in
                return self.externalService.token
            }
            .flatMap(weak: self, { (self, token) -> Single<Void> in
                return self.networkService.register(with: token, using: self.credentialsProvider)
            })
    }
}

// MARK: - RemoteNotificationDeviceTokenReceiving

extension RemoteNotificationService: RemoteNotificationDeviceTokenReceiving {
    func appDidFailToRegisterForRemoteNotifications(with error: Error) {
        Logger.shared.info("remote notification registration failed with error: \(error)")
    }
    
    func appDidRegisterForRemoteNotifications(with deviceToken: Data) {
        Logger.shared.info("remote notification registration failed")
        
        // FCM service must be informed about the new token
        externalService.didReceiveNewApnsToken(token: deviceToken)
        
        // Send the token
        sendTokenIfNeeded()
            .subscribe(
                onError: { error in
                    Logger.shared.error("Remote notification token could not be sent to the backend. received error: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
}
