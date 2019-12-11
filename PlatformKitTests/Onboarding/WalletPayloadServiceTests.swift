//
//  WalletPayloadServiceTests.swift
//  PlatformKitTests
//
//  Created by Daniel Huri on 10/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking

@testable import PlatformKit

class WalletPayloadServiceTests: XCTestCase {
    
    /// Tests a valid response to payload fetching that requires 2FA code
    func testValid2FAResponse() throws {
        let expectedAuthType = AuthenticatorType.sms // expect SMS
        let serverResponse = WalletPayloadClient.Response.fake(
            guid: "fake-guid", // expect this fake GUID value
            authenticatorType: expectedAuthType,
            payload: nil
        )
        let repository = MockWalletRepository()
        _ = try repository.set(sessionToken: "1234-abcd-5678-efgh").toBlocking().first()
        _ = try repository.set(guid: "fake-guid").toBlocking().first()
        let client = MockWalletPayloadClient(result: .success(serverResponse))
        let service = WalletPayloadService(
            client: client,
            repository: repository
        )
        do {
            let serviceAuthType = try service.requestUsingSessionToken().toBlocking().first()
            let repositoryAuthType = try repository.authenticatorType.toBlocking().first()
            XCTAssertEqual(repositoryAuthType, serviceAuthType)
            XCTAssertEqual(serviceAuthType, expectedAuthType)
        } catch {
            XCTFail("expected payload fetching to require \(expectedAuthType), got error: \(error)")
        }
    }
    
    func testValidPayloadResponse() throws {
        let expectedAuthType = AuthenticatorType.standard // expect no 2FA
        let serverResponse = WalletPayloadClient.Response.fake(
            guid: "fake-guid", // expect this fake GUID value
            authenticatorType: expectedAuthType,
            payload: "{\"pbkdf2_iterations\":1,\"version\":3,\"payload\":\"payload-for-wallet\"}"
        )
        let repository = MockWalletRepository()
        _ = try repository.set(sessionToken: "1234-abcd-5678-efgh").toBlocking().first()
        _ = try repository.set(guid: "fake-guid").toBlocking().first()
        let client = MockWalletPayloadClient(result: .success(serverResponse))
        let service = WalletPayloadService(
            client: client,
            repository: repository
        )
        do {
            let serviceAuthType = try service.requestUsingSessionToken().toBlocking().first()
            let repositoryAuthType = try repository.authenticatorType.toBlocking().first()
            XCTAssertEqual(repositoryAuthType, serviceAuthType)
            XCTAssertEqual(serviceAuthType, expectedAuthType)
            XCTAssertNotNil(try repository.payload.toBlocking().first())
        } catch {
            XCTFail("expected payload fetching to require \(expectedAuthType), got error: \(error)")
        }
    }
}
