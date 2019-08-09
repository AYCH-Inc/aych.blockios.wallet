//
//  MockNetworkManager.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

class MockNetworkManager: NetworkManager {

    private static let mockUrlString = "http://testurl.com"

    private var mockResponse: (HTTPURLResponse, JSON)?

    // MARK: - Test Methods

    func mockRequestJsonOrStringResponse(_ response: (HTTPURLResponse, JSON)) {
        mockResponse = response
    }

    func mockHTTPURLResponse(
        statusCode: Int = 400,
        urlString: String = MockNetworkManager.mockUrlString
    ) -> HTTPURLResponse {
        let url = URL(string: urlString)!
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    // MARK: - Overriden Methods

    override func requestJson(
        _ url: String,
        method: HTTPMethod,
        parameters: URLParameters? = nil,
        headers: URLHeaders? = nil
    ) -> Single<(HTTPURLResponse, JSON)> {
        guard let mockResponse = mockResponse else {
            print("No mock response set, performing actual network call")
            return super.requestJson(url, method: method, parameters: parameters)
        }
        return Single.just(mockResponse)
    }

}
