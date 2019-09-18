//
//  RemoteNotificationQueryBuilderTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import PlatformKit
@testable import Blockchain

final class RemoteNotificationQueryBuilderTests: XCTestCase {

    private let guid = "123-abc-456-def-789-ghi"
    private let sharedKey = "0123456789"
    private let token = "f16ff773-0cad-4788-a453-bd4b2bd33e17"

    func testBuildingWithEmptyArguments() {
        do {
            _ = try RemoteNotificationTokenQueryParametersBuilder(guid: "", sharedKey: "", token: "")
            XCTFail("expected builder to throw an error. got a success instead")
        } catch {}
    }

    func testBuildingWithEmptyGuid() {
        do {
            _ = try RemoteNotificationTokenQueryParametersBuilder(guid: "", sharedKey: sharedKey, token: token)
            XCTFail("expected builder to throw \(RemoteNotificationTokenQueryParametersBuilder.BuildError.guidIsEmpty). got a success instead")
        } catch {}
    }

    func testBuildingWithEmptySharedKey() {
        do {
            _ = try RemoteNotificationTokenQueryParametersBuilder(guid: guid, sharedKey: "", token: token)
            XCTFail("expected builder to throw \(RemoteNotificationTokenQueryParametersBuilder.BuildError.sharedKeyIsEmpty). got a success instead")
        } catch {}
    }

    func testBuildingWithEmptyToken() {
        do {
            _ = try RemoteNotificationTokenQueryParametersBuilder(guid: guid, sharedKey: sharedKey, token: "")
            XCTFail("expected builder to throw \(RemoteNotificationTokenQueryParametersBuilder.BuildError.tokenIsEmpty). got a success instead")
        } catch {}
    }
    
    func testBuildingWithValidParameters() {
        var data: Data?
        do {
            let builder = try RemoteNotificationTokenQueryParametersBuilder(guid: guid, sharedKey: sharedKey, token: token)
            data = builder.parameters
        } catch {
            XCTFail("expected builder to succeed. got a \(error) instead")
        }
        XCTAssertNotNil(data)
    }
}
