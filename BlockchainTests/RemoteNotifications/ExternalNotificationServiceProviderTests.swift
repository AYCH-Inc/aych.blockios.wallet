//
//  ExternalNotificationServiceProviderTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import UserNotifications
import PlatformKit

@testable import Blockchain

final class ExternalNotificationServiceProviderTests: XCTestCase {

    func testSuccessfullTokenFetching() {
        let expectedToken = "fcm-token-value"
        let tokenFetcher = MockFirebaseInstanceID(expectedResult: .success(expectedToken))
        let messagingService = MockMessagingService()
        let provider = ExternalNotificationServiceProvider(
            tokenFetcher: tokenFetcher,
            messagingService: messagingService
        )
        do {
            let token = try provider.token.toBlocking().first()!
            XCTAssertEqual(token, expectedToken)
        } catch {
            XCTFail("expected successful token fetch. got \(error) instead")
        }
    }
    
    func testEmptyTokenFetchingFailure() {
        let tokenFetcher = MockFirebaseInstanceID(expectedResult: .failure(.tokenIsEmpty))
        let messagingService = MockMessagingService()
        let provider = ExternalNotificationServiceProvider(
            tokenFetcher: tokenFetcher,
            messagingService: messagingService
        )
        do {
            let token = try provider.token.toBlocking().first()!
            XCTFail("expected \(RemoteNotification.TokenFetchError.tokenIsEmpty). got token \(token) instead")
        } catch RemoteNotification.TokenFetchError.tokenIsEmpty {
            // Okay
        } catch {
            XCTFail("expected \(RemoteNotification.TokenFetchError.tokenIsEmpty). got \(error) instead")
        }
    }
    
    func testTopicSubscriptionSuccess() {
        let tokenFetcher = MockFirebaseInstanceID(expectedResult: .success(""))
        let messagingService = MockMessagingService(shouldSubscribeToTopicsSuccessfully: true)
        let provider = ExternalNotificationServiceProvider(
            tokenFetcher: tokenFetcher,
            messagingService: messagingService
        )
        let topic = RemoteNotification.Topic.todo
        do {
            try provider.subscribe(to: topic).toBlocking().first()
            XCTAssertTrue(messagingService.topics.contains(topic))
        } catch {
            XCTFail("expected successful topic subscription. got \(error) instead")
        }
    }
    
    func testTopicSubscriptionFailure() {
        let tokenFetcher = MockFirebaseInstanceID(expectedResult: .failure(.tokenIsEmpty))
        let messagingService = MockMessagingService(shouldSubscribeToTopicsSuccessfully: false)
        let provider = ExternalNotificationServiceProvider(
            tokenFetcher: tokenFetcher,
            messagingService: messagingService
        )
        let topic = RemoteNotification.Topic.todo
        do {
            try provider.subscribe(to: topic).toBlocking().first()
            XCTFail("expected \(MockMessagingService.FakeError.subscriptionFailure) topic subscription. got success instead")
        } catch MockMessagingService.FakeError.subscriptionFailure {
            // Okay
        } catch {
            XCTFail("expected \(MockMessagingService.FakeError.subscriptionFailure) topic subscription. got \(error) instead")
        }
        
        XCTAssertFalse(messagingService.topics.contains(topic))
    }
}
