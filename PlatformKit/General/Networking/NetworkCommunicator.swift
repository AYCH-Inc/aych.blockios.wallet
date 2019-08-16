//
//  NetworkCommunicator.swift
//  Blockchain
//
//  Created by Jack on 07/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol NetworkCommunicatorAPI {
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable
    func perform<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> Single<Result<ResponseType, ErrorResponseType>>
    func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType>
    func perform<ResponseType: Decodable>(request: URLRequest) -> Single<ResponseType>
    func perform(request: NetworkRequest) -> Single<(HTTPURLResponse, Data?)>
    func perform(request: NetworkRequest) -> Single<(HTTPURLResponse, JSON)>
}

public enum NetworkCommunicatorError: Error {
    case clientError(HTTPRequestClientError)
    case serverError(HTTPRequestServerError)
    case payloadError(HTTPRequestPayloadError)
}

// TODO:
// * Handle network reachability

final public class NetworkCommunicator: NetworkCommunicatorAPI {
    
    private struct NetworkErrorResponse: Error {
        let data: Data?
    }
    
    public static let shared = Network.Dependencies.default.communicator
    
    private let scheduler: ConcurrentDispatchQueueScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    public func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable {
        let requestSingle: Single<ResponseType> = perform(request: request)
        return requestSingle.asCompletable()
    }
    
    @available(*, deprecated, message: "Don't use this")
    public func perform<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> Single<Result<ResponseType, ErrorResponseType>> {
        return execute(request: request.URLRequest)
            .flatMap { result -> Single<Result<ResponseType, ErrorResponseType>> in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                switch result {
                case .success(let responseTuple):
                    do {
                        let final: ResponseType
                        if let data = responseTuple.1 {
                            final = try decoder.decode(ResponseType.self, from: data)
                        } else {
                            throw NetworkCommunicatorError.payloadError(.badData)
                        }
                        return Single.just(.success(final))
                    } catch let decodingError {
                        Logger.shared.debug("Payload decoding error: \(decodingError)")
                        return .error(NetworkCommunicatorError.payloadError(.badData))
                    }
                case .failure(let error):
                    guard let data = error.data else {
                        return .error(NetworkCommunicatorError.payloadError(.badData))
                    }
                    do {
                        let payload = try decoder.decode(ErrorResponseType.self, from: data)
                        return .just(.failure(payload))
                    } catch {
                        return .error(NetworkCommunicatorError.payloadError(.badData))
                    }
                }
            }
    }
    
    public func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        return perform(request: request.URLRequest)
    }
    
    @available(*, deprecated, message: "Don't use this")
    public func perform(request: NetworkRequest) -> Single<(HTTPURLResponse, Data?)> {
        return execute(request: request.URLRequest)
            .map { result -> (HTTPURLResponse, Data?) in
                switch result {
                case .success(let data):
                    return data
                case .failure(let error):
                    throw error
                }
        
            }
    }
    
    @available(*, deprecated, message: "Don't use this")
    public func perform(request: NetworkRequest) -> Single<(HTTPURLResponse, JSON)> {
        return perform(request: request.URLRequest)
    }
    
    @available(*, deprecated, message: "Don't use this, prefer using NetworkRequest, this will be private in the future")
    public func perform<ResponseType: Decodable>(request: URLRequest) -> Single<ResponseType> {
        return executeAndDecode(request: request)
    }
    
    private func perform(request: URLRequest) -> Single<(HTTPURLResponse, JSON)> {
        return execute(request: request)
            .map { result -> (HTTPURLResponse, Data?) in
                switch result {
                case .success(let data):
                    return data
                case .failure(let error):
                    throw error
                }
            }
            .flatMap { (response, data) -> Single<(HTTPURLResponse, JSON)> in
                guard let data = data else {
                    throw NetworkCommunicatorError.payloadError(
                        HTTPRequestPayloadError.badData
                    )
                }
                let decodedJSONData = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDictionary = decodedJSONData as? JSON else {
                    throw NetworkCommunicatorError.payloadError(
                        HTTPRequestPayloadError.badData
                    )
                }
                return Single.just((response, jsonDictionary))
        }
    }
    
    private func executeAndDecode<ResponseType: Decodable>(request: URLRequest) -> Single<ResponseType> {
        return execute(request: request)
            .map { result -> (HTTPURLResponse, Data?) in
                switch result {
                case .success(let data):
                    return data
                case .failure(let error):
                    throw error
                }
            }
            .flatMap { (httpResponse, payload) -> Single<ResponseType> in
            // No need to decode if desired type is Void
            guard ResponseType.self != EmptyNetworkResponse.self else {
                let emptyResponse: ResponseType = EmptyNetworkResponse() as! ResponseType
                return Single.just(emptyResponse)
            }
            
            guard let payload = payload else {
                throw NetworkCommunicatorError.payloadError(.badData)
            }
            
            let final: ResponseType
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                final = try decoder.decode(ResponseType.self, from: payload)
            } catch let decodingError {
                Logger.shared.debug("Payload decoding error: \(decodingError)")
                return Single.error(NetworkCommunicatorError.payloadError(.badData))
            }
            return Single.just(final)
        }
    }
    
    // swiftlint:disable:next function_body_length
    private func execute(request: URLRequest) -> Single<Result<(HTTPURLResponse, Data?), NetworkErrorResponse>> {
        return Single<Result<(HTTPURLResponse, Data?), NetworkErrorResponse>>
            .create { [weak self] observer -> Disposable in
                let task = self?.session.dataTask(with: request) { payload, response, error in
                    if let error = error {
                        observer(.error(NetworkCommunicatorError.clientError(.failedRequest(description: error.localizedDescription))))
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        observer(.error(NetworkCommunicatorError.serverError(.badResponse)))
                        return
                    }
                    
                    guard let responseData = payload else {
                        observer(.error(NetworkCommunicatorError.payloadError(.emptyData)))
                        return
                    }
                    if let responseValue = String(data: responseData, encoding: .utf8) {
                        Logger.shared.info(responseValue)
                    }
                    let message = String(data: responseData, encoding: .utf8) ?? ""
                    Logger.shared.info(message)
                    guard (200...299).contains(httpResponse.statusCode) else {
                        observer(.success(.failure(NetworkErrorResponse(data: responseData))))
                        return
                    }
                    
                    observer(.success(.success((httpResponse, payload))))
                }
                defer {
                    task?.resume()
                }
                return Disposables.create {
                    task?.cancel()
                }
            }
            .subscribeOn(scheduler)
            .observeOn(scheduler)
    }
    
}
