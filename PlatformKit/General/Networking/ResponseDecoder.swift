//
//  ResponseDecoder.swift
//  PlatformKit
//
//  Created by Jack on 21/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public struct NetworkResponse {
    let response: HTTPURLResponse
    let payload: Data?
}

public struct NetworkErrorResponse: Error {
    let response: HTTPURLResponse
    let payload: Data?
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Result<NetworkResponse, NetworkErrorResponse> {
    func decode<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(with decoder: NetworkResponseDecoderAPI) -> Single<Result<ResponseType, ErrorResponseType>> {
        return flatMap { result -> Single<Result<ResponseType, ErrorResponseType>> in
            decoder.decode(result: result)
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == NetworkResponse {
    func decode<ResponseType: Decodable>(with decoder: NetworkResponseDecoderAPI) -> Single<ResponseType> {
        return flatMap { response -> Single<ResponseType> in
            decoder.decode(response: response)
        }
    }
}

public protocol NetworkResponseDecoderAPI {
    func decode<ResponseType: Decodable>(response: NetworkResponse) -> Single<ResponseType>
    func decode<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(result: Result<NetworkResponse, NetworkErrorResponse>) -> Single<Result<ResponseType, ErrorResponseType>>
    func decodeFailure<ErrorResponseType: Error & Decodable>(errorResponse: NetworkErrorResponse) throws -> Result<Never, ErrorResponseType>
}

public class NetworkResponseDecoder: NetworkResponseDecoderAPI {
    
    // FIXME: Fetch decoder from Container (in the future)
    public static let `default` = NetworkResponseDecoder()
    
    public static let defaultJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    private let jsonDecoder: JSONDecoder
    
    public init(jsonDecoder: JSONDecoder = NetworkResponseDecoder.defaultJSONDecoder) {
        self.jsonDecoder = jsonDecoder
    }
    
    public func decode<ResponseType: Decodable>(response: NetworkResponse) -> Single<ResponseType> {
        let result: Result<ResponseType, Never>
        do {
            result = try self.decodeSuccess(response: response)
        } catch {
            return Single.error(error)
        }
        return result.flatMapError(to: Error.self).single
    }
    
    public func decode<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(result: Result<NetworkResponse, NetworkErrorResponse>) -> Single<Result<ResponseType, ErrorResponseType>> {
        switch result {
        case .success(let networkResponse):
            let response: Result<ResponseType, Never>
            do {
                response = try decodeSuccess(response: networkResponse)
            } catch {
                return Single.error(error)
            }
            return Single.just(response.flatMapError())
        case .failure(let networkErrorResponse):
            let errorResult: Result<Never, ErrorResponseType>
            do {
                errorResult = try decodeFailure(errorResponse: networkErrorResponse)
            } catch {
                return Single.error(error)
            }
            return Single.just(errorResult.flatMapSuccess())
        }
    }
    
    public func decodeFailure<ErrorResponseType: Error & Decodable>(errorResponse: NetworkErrorResponse) throws -> Result<Never, ErrorResponseType> {
        guard let payload = errorResponse.payload else {
            throw NetworkCommunicatorError.payloadError(.emptyData)
        }
        let decodedErrorResponse: ErrorResponseType
        do {
            decodedErrorResponse = try self.jsonDecoder.decode(ErrorResponseType.self, from: payload)
        } catch let decodingError {
            Logger.shared.debug("Error payload decoding error: \(decodingError)")
            throw NetworkCommunicatorError.payloadError(.badData)
        }
        return .failure(decodedErrorResponse)
    }
    
    private func decodeSuccess<ResponseType: Decodable>(response: NetworkResponse) throws -> Result<ResponseType, Never> {
        guard ResponseType.self != EmptyNetworkResponse.self else {
            let emptyResponse: ResponseType = EmptyNetworkResponse() as! ResponseType
            return .success(emptyResponse)
        }
        guard let payload = response.payload else {
            throw NetworkCommunicatorError.payloadError(.emptyData)
        }
        let decodedResponse: ResponseType
        do {
            decodedResponse = try self.jsonDecoder.decode(ResponseType.self, from: payload)
        } catch let decodingError {
            Logger.shared.debug("Payload decoding error: \(decodingError)")
            throw NetworkCommunicatorError.payloadError(.badData)
        }
        return .success(decodedResponse)
    }
}


