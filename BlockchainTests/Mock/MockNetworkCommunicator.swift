//
//  MockCommunicator.swift
//  BlockchainTests
//
//  Created by Jack on 13/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import Blockchain

enum CommunicatorMockError: Error {
    case mockError
    case decodingError
}

class MockNetworkCommunicator: NetworkCommunicatorAPI {
    
    func perform<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> Single<Result<ResponseType, ErrorResponseType>> {
        fatalError("This method is deprecated and will never be implemented")
    }

    func perform(request: NetworkRequest) -> Single<(HTTPURLResponse, Data?)> {
        fatalError("This method is deprecated and will never be implemented")
    }
    
    func perform<ResponseType: Decodable>(request: URLRequest) -> Single<ResponseType> {
        fatalError("This method is deprecated and will never be implemented")
    }
    
    func perform(request: NetworkRequest) -> Single<(HTTPURLResponse, JSON)> {
        fatalError("This method is deprecated and will never be implemented")
    }
    
    var perfomRequestResponseFixuture: String!
    public func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable {
        let single: Single<ResponseType> = decode(fixture: perfomRequestResponseFixuture)
        return single.asCompletable()
    }
    
    var perfomRequestResponseFixture: String!
    public func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        return decode(fixture: perfomRequestResponseFixture)
    }
    
    func decode<ResponseType: Decodable>(fixture name: String) -> Single<ResponseType> {
        guard let fixture: ResponseType = Fixtures.load(name: name) else {
            return Single.error(CommunicatorMockError.decodingError)
        }
        return Single.just(fixture)
    }
}
