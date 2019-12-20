//
//  WalletSettingsService.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit
import PlatformKit

/// Concrete implementation of WalletSettingsAPI
class WalletSettingsService: WalletSettingsAPI {

    private let apiCode: String
    private let communicator: NetworkCommunicatorAPI

    init(apiCode: String = BlockchainAPI.Parameters.apiCode, communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.apiCode = apiCode
        self.communicator = communicator
    }

    func fetchSettings(guid: String, sharedKey: String) -> Single<WalletSettings> {
        guard let url = URL(string: BlockchainAPI.shared.walletSettingsUrl) else {
            return Single.error(NetworkError.generic(message: "Cannot retrieve wallet settings URL."))
        }
        let request = WalletSettingsRequest(
            method: WalletSettingsApiMethod.getInfo.rawValue,
            guid: guid,
            sharedKey: sharedKey,
            apiCode: apiCode
        )
        let data = try? JSONEncoder().encode(request)
        return communicator.perform(
            request: NetworkRequest(
                endpoint: url,
                method: .post,
                body: data,
                contentType: .formUrlEncoded
            )
        )
    }

    func updateSettings(method: WalletSettingsApiMethod, guid: String, sharedKey: String, payload: String, context: ContextParameter?) -> Completable {
        guard let url = URL(string: BlockchainAPI.shared.walletSettingsUrl) else {
            return Completable.error(NetworkError.generic(message: "Cannot retrieve wallet settings URL."))
        }

        let request = WalletSettingsRequest(
            method: method.rawValue,
            guid: guid,
            sharedKey: sharedKey,
            apiCode: apiCode,
            payload: payload,
            length: "\(payload.count)",
            format: WalletSettingsRequest.Formats.plain,
            context: context?.rawValue ?? nil
        )
        let data = try? JSONEncoder().encode(request)
        return communicator.perform(
            request: NetworkRequest(
                endpoint: url,
                method: .post,
                body: data,
                contentType: .formUrlEncoded
            )
        )
    }

    func updateLastTxTimeToCurrentTime(guid: String, sharedKey: String) -> Completable {
        let currentTime = "\(Int(Date().timeIntervalSince1970))"
        return updateSettings(method: .updateLastTxTime, guid: guid, sharedKey: sharedKey, payload: currentTime, context: nil)
    }

    func updateEmail(email: String, guid: String, sharedKey: String, context: ContextParameter?) -> Completable {
        return updateSettings(method: .updateEmail, guid: guid, sharedKey: sharedKey, payload: email, context: context)
    }
}
