//
//  PinScreenInteractionTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import PlatformKit

@testable import Blockchain

/// Tests the pin interactor
class PinInteractorTests: XCTestCase {
    
    enum Operation {
        case creation
        case validation
    }
    
    var maintenanceService: MaintenanceServicing {
        return MockWalletService()
    }
    
    var wallet: WalletProtocol {
        return MockWalletData(initialized: true, delegate: nil)
    }
    
    var appSettings: MockAppSettings {
        return MockAppSettings()
    }
    
    var credentialsProvider: WalletCredentialsProviding {
        return MockWalletCredentialsProvider.validFake
    }
    
    // MARK: - Test success cases
    
    func testCreation() throws {
        try testPin(operation: .creation)
    }
    
    func testValidation() throws {
        try testPin(operation: .validation)
    }
    
    /// Tests PIN operation
    private func testPin(operation: Operation) throws {
        let interactor = PinInteractor(
            credentialsProvider: credentialsProvider,
            pinClient: MockPinClient(statusCode: .success),
            maintenanceService: maintenanceService,
            wallet: wallet,
            appSettings: appSettings
        )
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)
        switch operation {
        case .creation:
            _ = try interactor.create(using: payload).toBlocking().first()
        case .validation:
            _ = try interactor.validate(using: payload).toBlocking().first()
        }
    }
    
    // MARK: - Maintenance Error
    
    func testMaintenanceWhileValidating() throws {
        try testMaintenanceError(for: .validation)
    }
    
    func testMaintenanceWhileCreating() throws {
        try testMaintenanceError(for: .creation)
    }
    
    // Maintenance error is returned in the relevant case
    private func testMaintenanceError(for opeation: Operation) throws {
        let expectedMessage = "server under maintenance"
        let maintenanceService = MockWalletService(message: expectedMessage)
        let interactor = PinInteractor(pinClient: MockPinClient(statusCode: .success),
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: appSettings)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)
        
        do {
            switch opeation {
            case .creation:
                _ = try interactor.create(using: payload).toBlocking().first()
            case .validation:
                _ = try interactor.validate(using: payload).toBlocking().first()
            }
            XCTAssert(false)
        } catch {
            let error = error as! PinError
            switch error {
            case .serverMaintenance(message: let message) where message == expectedMessage:
                XCTAssert(true)
            default:
                XCTAssert(false)
            }
        }
    }
    
    // MARK: - Incorrect PIN validation
    
    // Incorrect pin returns proper error
    func testIncorrectPinValidation() throws {
        let interactor = PinInteractor(pinClient: MockPinClient(statusCode: .incorrect),
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: appSettings)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch PinError.incorrectPin {
            XCTAssert(true)
        }
    }
    
    // Too many failed validation attempts
    func testTooManyFailedValidationAttempts() throws {
        let interactor = PinInteractor(pinClient: MockPinClient(statusCode: .deleted),
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: appSettings)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch PinError.tooManyAttempts {
            XCTAssert(true)
        }
    }
    
    // Invalid status code in response should lead to an exception
    func testFailureOnInvalidStatusCode() throws {
        let interactor = PinInteractor(
            pinClient: MockPinClient(statusCode: nil),
            maintenanceService: maintenanceService,
            wallet: wallet,
            appSettings: appSettings
        )
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch {
            XCTAssert(true)
        }
    }
    
    // Tests the the pin is persisted no app-settings object after validating payload
    func testPersistingPinAfterValidation() throws {
        let settings = MockAppSettings()
        let interactor = PinInteractor(pinClient: MockPinClient(statusCode: .success),
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: settings)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: true)
        _ = try interactor.validate(using: payload).toBlocking().first()
        XCTAssertNotNil(settings.pin)
        XCTAssertNotNil(settings.biometryEnabled)
    }
    
    // Test that an error is thrown in case the server returns an error
    func testServerErrorWhileCreatingPin() throws {
        struct ServerError: Error {}
        let pinClient = MockPinClient(statusCode: .success, error: "server error")
        let interactor = PinInteractor(pinClient: pinClient,
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: appSettings)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: true)
        do {
            _ = try interactor.create(using: payload).toBlocking().first()
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
}
