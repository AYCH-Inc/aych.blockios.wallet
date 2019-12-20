//
//  MockCommunicator.swift
//  BlockchainTests
//
//  Created by Jack on 13/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import NetworkKit
import PlatformKit
import Blockchain
import TestKit

enum CommunicatorMockError: Error {
    case mockError
    case decodingError
}

class MockNetworkCommunicator: NetworkCommunicatorAPI {
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType> {
        return decode(fixture: perfomRequestResponseFixture)
    }
    
    @available(*, deprecated, message: "Don't use this")
    func perform<ResponseType, ErrorResponseType>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> PrimitiveSequence<SingleTrait, Result<ResponseType, ErrorResponseType>> where ResponseType : Decodable, ErrorResponseType : Decodable, ErrorResponseType : Error {
        fatalError("This method is deprecated and will never be implemented")
    }
    
    func perform(request: NetworkRequest) -> Completable {
        return Completable.empty()
    }
    
    var perfomRequestWithResponseTypeFixture: String!
    public func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable {
        let single: Single<ResponseType> = decode(fixture: perfomRequestWithResponseTypeFixture)
        return single.asCompletable()
    }
    
    var perfomRequestResponseFixture: String!
    public func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        return decode(fixture: perfomRequestResponseFixture)
    }
    
    func decode<ResponseType: Decodable>(fixture name: String) -> Single<ResponseType> {
        guard let fixture: ResponseType = Fixtures.load(name: name, in: Bundle(for: MockNetworkCommunicator.self)) else {
            return Single.error(CommunicatorMockError.decodingError)
        }
        return Single.just(fixture)
    }
}
