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
    func prices(within window: PriceWindow, currency: CryptoCurrency, code: String) -> Single<[PriceInFiat]>
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
    
    func prices(within window: PriceWindow, currency: CryptoCurrency, code: String) -> Single<[PriceInFiat]> {
        var start: TimeInterval = 0
        switch window {
        case .all:
            start = currency.maxStartDate
        case .day:
            start = Date().addingTimeInterval(-86400).timeIntervalSince1970
        case .week:
            start = Date().addingTimeInterval(-604800).timeIntervalSince1970
        case .month:
            start = Date().addingTimeInterval(-2592000).timeIntervalSince1970
        case .year:
            start = Date().addingTimeInterval(-31536000).timeIntervalSince1970
        }
        
        let parameters = [
            URLQueryItem(
                name: "base",
                value: currency.symbol
            ),
            URLQueryItem(
                name: "quote",
                value: code
            ),
            URLQueryItem(
                name: "start",
                value: String(Int(start))
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

fileprivate extension CryptoCurrency {
    var maxStartDate: TimeInterval {
        switch self {
        case .bitcoin:
            return 1282089600.0
        case .bitcoinCash:
            return 1500854400.0
        case .ethereum:
            return 1438992000.0
        case .pax:
            return 1555060318.0
        case .stellar:
            return 1525716000.0
        }
    }
}
