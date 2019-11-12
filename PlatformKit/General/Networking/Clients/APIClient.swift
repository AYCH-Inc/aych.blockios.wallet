//
//  APIClient.swift
//  PlatformKit
//
//  Created by Jack on 25/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

enum APIClientError: Error {
    case unknown
}

protocol APIClientAPI: AirdropRegistrationAPI {
    func prices(within window: PriceWindow) -> Single<[PriceInFiat]>
}

final class APIClient: APIClientAPI {
    
    struct Endpoint {
        
        static let airdropRegistration = [ "nabu-gateway", "users", "register-campaign" ]
        static let priceIndex = [ "price", "index-series" ]
    }
    
    // MARK: - Private properties

    private let communicator: NetworkCommunicatorAPI
    private let config: Network.Config
    private let requestBuilder: RequestBuilder
    
    // MARK: - Init

    init(communicator: NetworkCommunicatorAPI = Network.Dependencies.default.communicator,
         config: Network.Config = Network.Dependencies.default.blockchainAPIConfig,
         requestBuilder: RequestBuilder = RequestBuilder(networkConfig: Network.Dependencies.default.blockchainAPIConfig)) {
        self.communicator = communicator
        self.config = config
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - APIClientAPI
    
    func prices(within window: PriceWindow) -> Single<[PriceInFiat]> {
        let parameters = [
            URLQueryItem(
                name: "base",
                value: window.symbol
            ),
            URLQueryItem(
                name: "quote",
                value: window.code
            ),
            URLQueryItem(
                name: "start",
                value: String(window.start)
            ),
            URLQueryItem(
                name: "scale",
                value: String(window.scale)
            ),
            URLQueryItem(
                name: "omitnull",
                value: "true"
            )
        ]
        guard let request = requestBuilder.get(path: Endpoint.priceIndex, parameters: parameters) else {
            return Single.error(APIClientError.unknown)
        }
        return communicator.perform(request: request)
    }
    
    func submitRegistrationRequest(_ registrationRequest: AirdropRegistrationRequest) -> Single<AirdropRegistrationResponse> {
        let payload = AirdropRegistrationPayload(
            publicKey: registrationRequest.publicKey,
            isNewUser: registrationRequest.newUser
        )
        let data = try? JSONEncoder().encode(payload)
        
        let headers: HTTPHeaders = [HttpHeaderField.authorization: registrationRequest.authToken,
                                    HttpHeaderField.airdropCampaign: registrationRequest.campaignIdentifier]
        
        guard let request = requestBuilder.put(path: Endpoint.airdropRegistration, body: data, headers: headers) else {
            return Single.error(APIClientError.unknown)
        }
        return communicator.perform(request: request)
        
    }
}
