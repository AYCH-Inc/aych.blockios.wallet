//
//  MockRemoteNotificationAuthorizer.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UserNotifications
import RxSwift

@testable import Blockchain

final class MockRemoteNotificationAuthorizer {
    private let expectedAuthorizationStatus: UNAuthorizationStatus
    private let authorizationRequestExpectedStatus: Result<Void, RemoteNotificationAuthorizer.ServiceError>
    
    init(expectedAuthorizationStatus: UNAuthorizationStatus,
         authorizationRequestExpectedStatus: Result<Void, RemoteNotificationAuthorizer.ServiceError>) {
        self.expectedAuthorizationStatus = expectedAuthorizationStatus
        self.authorizationRequestExpectedStatus = authorizationRequestExpectedStatus
    }
}

// MARK: - RemoteNotificationAuthorizationStatusProviding

extension MockRemoteNotificationAuthorizer: RemoteNotificationAuthorizationStatusProviding {
    var status: Single<UNAuthorizationStatus> {
        return .just(expectedAuthorizationStatus)
    }
}

// MARK: - RemoteNotificationRegistering

extension MockRemoteNotificationAuthorizer: RemoteNotificationRegistering {
    func registerForRemoteNotificationsIfAuthorized() -> Single<Void> {
        if expectedAuthorizationStatus == .authorized {
            return .just(())
        } else {
            return .error(RemoteNotificationAuthorizer.ServiceError.unauthorizedStatus)
        }
    }
}

// MARK: - RemoteNotificationAuthorizing

extension MockRemoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting {
    func requestAuthorizationIfNeeded() -> Single<Void> {
        return authorizationRequestExpectedStatus.single
    }
}
