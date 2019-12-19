//
//  WalletNabuSynchronizerService.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit
import PlatformKit

class WalletNabuSynchronizerService: WalletNabuSynchronizerAPI {

    private let appSettings: BlockchainSettings.App
    private let communictator: NetworkCommunicatorAPI

    init(appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
         communictator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.appSettings = appSettings
        self.communictator = communictator
    }

    func sync(token: NabuSessionTokenResponse) -> Single<NabuUser> {
        return getSignedRetailToken().flatMap { signedRetailToken -> Single<NabuUser> in

            // Error checking
            guard signedRetailToken.success else {
                return Single.error(NetworkError.generic(message: "Signed retail token failed."))
            }

            guard let jwtToken = signedRetailToken.token else {
                return Single.error(NetworkError.generic(message: "Signed retail token is nil."))
            }

            // If all passes, send JWT to Nabu
            let headers = [HttpHeaderField.authorization: token.token]
            let payload = ["jwt": jwtToken]
            return KYCNetworkRequest.request(
                put: .updateWalletInformation,
                parameters: payload,
                headers: headers,
                type: NabuUser.self
            )
        }
    }

    func getSignedRetailToken() -> Single<SignedRetailTokenResponse> {
        // Construct URL
        guard let walletGuid = appSettings.guid else {
            return Single.error(NabuAuthenticationError.invalidGuid)
        }
        guard let sharedKey = appSettings.sharedKey else {
            return Single.error(NabuAuthenticationError.invalidSharedKey)
        }

        let requestPayload = SignedRetailTokenRequest(
            apiCode: BlockchainAPI.Parameters.apiCode,
            sharedKey: sharedKey,
            walletGuid: walletGuid
        )
        guard
            let baseUrl = URL(string: BlockchainAPI.shared.signedRetailTokenUrl),
            let url = URL.endpoint(baseUrl, pathComponents: nil, queryParameters: requestPayload.toDictionary)
        else {
            return Single.error(NabuAuthenticationError.invalidUrl)
        }
        // Initiate request
        return communictator.perform(request: NetworkRequest(endpoint: url, method: .get))
    }

}
