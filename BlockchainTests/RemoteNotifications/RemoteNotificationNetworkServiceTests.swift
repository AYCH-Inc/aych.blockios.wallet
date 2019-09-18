//
//  RemoteNotificationNetworkServiceTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 18/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import UserNotifications
import PlatformKit

@testable import Blockchain

final class RemoteNotificationNetworkServiceTests: XCTestCase {
    
    private enum Fixture: String {
        case success = "remote-notification-registration-success"
        case failure = "remote-notification-registration-failure"
    }
    
    func testHttpCodeOkWithSuccess() {
        let token = "remote-notification-token"
        let credentialsProvider = MockWalletCredentialsProvider.validFake
        let service = prepareServiceForHttpCodeOk(with: .success)
        let observable = service.register(with: token, using: credentialsProvider).toBlocking()
        
        do {
            try observable.first()
        } catch {
            XCTFail("expected successful token registration. got \(error) instead")
        }
    }
    
    func testHttpCodeOkWithFailure() {
        let token = "remote-notification-token"
        let credentialsProvider = MockWalletCredentialsProvider.validFake
        let service = prepareServiceForHttpCodeOk(with: .failure)
        let observable = service.register(with: token, using: credentialsProvider).toBlocking()
        
        do {
            try observable.first()
            XCTFail("expected \(RemoteNotificationNetworkService.PushNotificationError.registrationFailure) token registration. got success instead")
        } catch RemoteNotificationNetworkService.PushNotificationError.registrationFailure {
            // Okay
        } catch {
            XCTFail("expected \(RemoteNotificationNetworkService.PushNotificationError.registrationFailure) token registration. got \(error) instead")
        }
    }
    
    private func prepareServiceForHttpCodeOk(with fixture: Fixture) -> RemoteNotificationNetworkService {
        let communicator = MockNetworkCommunicator()
        communicator.perfomRequestResponseFixture = fixture.rawValue
        let service = RemoteNotificationNetworkService(communicator: communicator)
        return service
    }
}
