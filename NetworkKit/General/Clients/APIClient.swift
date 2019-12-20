//
//  APIClient.swift
//  PlatformKit
//
//  Created by Jack on 25/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import ToolKit

enum APIClientError: Error {
    case unknown
}

public protocol APIClientAPI {
    
    func prices(base: String, quote: String, start: String, scale: String) -> Single<[PriceInFiatResponse]>
    
    func submitRegistrationRequest(_ registrationRequest: AirdropRegistrationRequest) -> Single<AirdropRegistrationResponse>
}

public final class APIClient: APIClientAPI {
    
    struct Endpoint {
        
        static let airdropRegistration = [ "nabu-gateway", "users", "register-campaign" ]
        static let priceIndex = [ "price", "index-series" ]
    }
    
    // MARK: - Private properties

    private let communicator: NetworkCommunicatorAPI
    private let config: Network.Config
    private let requestBuilder: RequestBuilder
    
    // MARK: - Init

    public init(communicator: NetworkCommunicatorAPI = Network.Dependencies.default.communicator,
         config: Network.Config = Network.Dependencies.default.blockchainAPIConfig,
         requestBuilder: RequestBuilder = RequestBuilder(networkConfig: Network.Dependencies.default.blockchainAPIConfig)) {
        self.communicator = communicator
        self.config = config
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - APIClientAPI
    
    public func prices(base: String, quote: String, start: String, scale: String) -> Single<[PriceInFiatResponse]> {
        let parameters = [
            URLQueryItem(
                name: "base",
                value: base
            ),
            URLQueryItem(
                name: "quote",
                value: quote
            ),
            URLQueryItem(
                name: "start",
                value: start
            ),
            URLQueryItem(
                name: "scale",
                value: scale
            )
        ]
        guard let request = requestBuilder.get(path: Endpoint.priceIndex, parameters: parameters) else {
            return Single.error(APIClientError.unknown)
        }
        return communicator.perform(request: request)
    }
    
    public func submitRegistrationRequest(_ registrationRequest: AirdropRegistrationRequest) -> Single<AirdropRegistrationResponse> {
        let payload = AirdropRegistrationPayload(
            publicKey: registrationRequest.publicKey,
            isNewUser: registrationRequest.newUser
        )
        let data = try? JSONEncoder().encode(payload)
        
        let headers: HTTPHeaders = [
            HttpHeaderField.authorization: registrationRequest.authToken,
            HttpHeaderField.airdropCampaign: registrationRequest.campaignIdentifier
        ]
        
        guard let request = requestBuilder.put(path: Endpoint.airdropRegistration, body: data, headers: headers) else {
            return Single.error(APIClientError.unknown)
        }
        return communicator.perform(request: request)
    }
}
