//
//  SettingsClient.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public final class SettingsClient: SettingsClientAPI {
        
    /// Enumerates the API methods supported by the wallet settings endpoint.
    enum Method: String {
        case getInfo = "get-info"
        case verifyEmail = "verify-email"
        case verifySms = "verify-sms"
        case updateNotificationType = "update-notifications-type"
        case updateNotificationOn = "update-notifications-on"
        case updateSms = "update-sms"
        case updateEmail = "update-email"
        case updateBtcCurrency = "update-btc-currency"
        case updateCurrency = "update-currency"
        case updatePasswordHint  = "update-password-hint1"
        case updateAuthType = "update-auth-type"
        case updateBlockTorIps = "update-block-tor-ips"
        case updateLastTxTime = "update-last-tx-time"
    }
    
    // MARK: - Private Properties
    
    private let apiCode: String
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    public init(apiCode: String = BlockchainAPI.Parameters.apiCode,
                communicator: NetworkCommunicatorAPI = Network.Dependencies.default.communicator) {
        self.apiCode = apiCode
        self.communicator = communicator
    }
    
    /// Fetches the wallet settings from the backend.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Single` that wraps a `SettingsResponse`.
    public func settings(by guid: String, sharedKey: String) -> Single<SettingsResponse> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                let url = URL(string: BlockchainAPI.shared.walletSettingsUrl)!
                let payload = SettingsRequest(
                    method: Method.getInfo.rawValue,
                    guid: guid,
                    sharedKey: sharedKey,
                    apiCode: self.apiCode
                )
                let data = try? JSONEncoder().encode(payload)
                let request = NetworkRequest(
                    endpoint: url,
                    method: .post,
                    body: data,
                    contentType: .formUrlEncoded
                )
                observer(.success(request))
                return Disposables.create()
            }
            .flatMap(weak: self) { (self, request) -> Single<SettingsResponse> in
                return self.communicator.perform(request: request)
            }
    }
    
    /// Updates the last tx time.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Completable`.
    public func updateLastTransactionTime(guid: String, sharedKey: String) -> Completable {
        let currentTime = "\(Int(Date().timeIntervalSince1970))"
        return update(
            guid: guid,
            sharedKey: sharedKey,
            method: .updateLastTxTime,
            payload: currentTime
        )
    }

    /// Updates the user's email.
    /// - Parameter email: The email value.
    /// - Parameter context: The context in which the update is happening.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Completable`.
    public func update(email: String,
                       context: FlowContext?,
                       guid: String,
                       sharedKey: String) -> Completable {
        return update(
            guid: guid,
            sharedKey: sharedKey,
            method: .updateEmail,
            payload: email,
            context: context
        )
    }
    
    public func emailNotifications(enabled: Bool, guid: String, sharedKey: String) -> Completable {
        return update(
            guid: guid,
            sharedKey: sharedKey,
            method: .updateNotificationType,
            payload: enabled ? "1" : "0"
        ).andThen(
            update(
                guid: guid,
                sharedKey: sharedKey,
                method: .updateNotificationOn,
                payload: enabled ? "1" : "0"
            )
        )
    }
    
    /// A generic update method that is able to update email, mobile number, etc.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Parameter method: A method indicating the updated user information.
    /// - Parameter payload: A raw payload associated with the type of updated content.
    /// - Parameter context: The context in which the update is happening.
    /// - Returns: a `Completable`.
    private func update(guid: String,
                        sharedKey: String,
                        method: Method,
                        payload: String,
                        context: FlowContext? = nil) -> Completable {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                let url = URL(string: BlockchainAPI.shared.walletSettingsUrl)!
                let requestPayload = SettingsRequest(
                    method: method.rawValue,
                    guid: guid,
                    sharedKey: sharedKey,
                    apiCode: self.apiCode,
                    payload: payload,
                    length: "\(payload.count)",
                    format: SettingsRequest.Formats.plain,
                    context: context?.rawValue
                )
                let data = try? JSONEncoder().encode(requestPayload)
                let request = NetworkRequest(
                    endpoint: url,
                    method: .post,
                    body: data,
                    contentType: .formUrlEncoded
                )
                observer(.success(request))
                return Disposables.create()
            }
            .flatMapCompletable(weak: self) { (self, request) -> Completable in
                return self.communicator.perform(request: request)
            }
    }
}
