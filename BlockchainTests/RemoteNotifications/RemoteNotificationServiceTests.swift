//
//  RemoteNotificationServiceTests.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import PlatformKit

@testable import Blockchain

final class RemoteNotificationServiceTests: XCTestCase {
    
    // MARK: - Wide range interaction testing
    
    func testTokenSendingSuccessUsingRealServices() {
        
        // Instantiate all the mock services needed to test the notification domain
        
        let token = "remote-notification-token"
        let registry = MockRemoteNotificationsRegistry()
        let userNotificationCenter = MockUNUserNotificationCenter(
            initialAuthorizationStatus: .authorized,
            expectedAuthorizationResult: .success(true)
        )
        let messagingService = MockMessagingService()
        let tokenFetcher = MockFirebaseInstanceID(expectedResult: .success(token))
        let credentialsProvider = MockWalletCredentialsProvider.validFake
        let communicator = MockNetworkCommunicator()
        communicator.perfomRequestResponseFixture = "remote-notification-registration-success"
        
        // Instantiate all the sub services
        
        let authorizer = RemoteNotificationAuthorizer(
            application: registry,
            userNotificationCenter: userNotificationCenter,
            options: [.alert, .badge, .sound]
        )
        let relay = RemoteNotificationRelay(
            userNotificationCenter: userNotificationCenter,
            messagingService: messagingService
        )
        let externalServiceProvider = ExternalNotificationServiceProvider(
            tokenFetcher: tokenFetcher,
            messagingService: messagingService
        )
        let networkService = RemoteNotificationNetworkService(communicator: communicator)
        
        // Instantiate the main service
        
        let service = RemoteNotificationService(
            authorizer: authorizer,
            relay: relay,
            externalService: externalServiceProvider,
            networkService: networkService,
            credentialsProvider: credentialsProvider
        )
        
        let observable = service.sendTokenIfNeeded().toBlocking()
        do {
            try observable.first()!
        } catch {
            XCTFail("expected success. got \(error) instead")
        }
    }
    
    // MARK: - Happy Scenarios using mocks
    
    func testRegistrationAndTokenSendingAreSuccessfulUsingMockServices() {
        let service: RemoteNotificationTokenSending = RemoteNotificationService(
            authorizer: MockRemoteNotificationAuthorizer(
                expectedAuthorizationStatus: .authorized,
                authorizationRequestExpectedStatus: .success(())
            ),
            relay: MockRemoteNotificationRelay(),
            externalService: MockExternalNotificationServiceProvider(
                expectedTokenResult: .success("firebase-token-value"),
                expectedTopicSubscriptionResult: .success(())
            ),
            networkService: MockRemoteNotificationNetworkService(expectedResult: .success(())),
            credentialsProvider: MockWalletCredentialsProvider.validFake)
        
        let result = service.sendTokenIfNeeded().toBlocking()
        
        do {
            try result.first()
        } catch {
            XCTFail("expected token to be sent successfully, got \(error) instead")
        }
    }
    
    // MARK: - Unauthorized permission
    
    func testTokenSendWithUnauthorizedPermissionsUsingMockServices() {
        let service: RemoteNotificationTokenSending = RemoteNotificationService(
            authorizer: MockRemoteNotificationAuthorizer(
                expectedAuthorizationStatus: .denied,
                authorizationRequestExpectedStatus: .success(())
            ),
            relay: MockRemoteNotificationRelay(),
            externalService: MockExternalNotificationServiceProvider(
                expectedTokenResult: .success("firebase-token-value"),
                expectedTopicSubscriptionResult: .success(())
            ),
            networkService: MockRemoteNotificationNetworkService(expectedResult: .success(())),
            credentialsProvider: MockWalletCredentialsProvider.validFake)
        
        let result = service.sendTokenIfNeeded().toBlocking()

        do {
            try result.first()
            XCTFail("expected permission authorization. got success instead")
        } catch {}
    }
    
    // MARK: - Unauthorized permission
    
    func testTokenSendWithExternalServiceFetchingFailure() {
        let service: RemoteNotificationTokenSending = RemoteNotificationService(
            authorizer: MockRemoteNotificationAuthorizer(
                expectedAuthorizationStatus: .authorized,
                authorizationRequestExpectedStatus: .success(())
            ),
            relay: MockRemoteNotificationRelay(),
            externalService: MockExternalNotificationServiceProvider(
                expectedTokenResult: .failure(.init(info: "token fetch failure")),
                expectedTopicSubscriptionResult: .success(())
            ),
            networkService: MockRemoteNotificationNetworkService(expectedResult: .success(())),
            credentialsProvider: MockWalletCredentialsProvider.validFake)
        
        let result = service.sendTokenIfNeeded().toBlocking()
        
        do {
            try result.first()
            XCTFail("expected failure fetching the token. got success instead")
        } catch {}
    }
    
    // MARK: - Unauthorized permission
    
    func testTokenSendWithNetworkServiceFailure() {
        let service: RemoteNotificationTokenSending = RemoteNotificationService(
            authorizer: MockRemoteNotificationAuthorizer(
                expectedAuthorizationStatus: .authorized,
                authorizationRequestExpectedStatus: .success(())
            ),
            relay: MockRemoteNotificationRelay(),
            externalService: MockExternalNotificationServiceProvider(
                expectedTokenResult: .success("firebase-token-value"),
                expectedTopicSubscriptionResult: .success(())
            ),
            networkService: MockRemoteNotificationNetworkService(expectedResult: .failure(.registrationFailure)),
            credentialsProvider: MockWalletCredentialsProvider.validFake)
        
        let result = service.sendTokenIfNeeded().toBlocking()
        
        do {
            try result.first()
            XCTFail("expected failure sending the token. got success instead")
        } catch {}
    }
}
