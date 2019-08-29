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
    func perform(request: NetworkRequest) -> Completable
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable
    func perform<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> Single<Result<ResponseType, ErrorResponseType>>
    func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType>
}

public enum NetworkCommunicatorError: Error {
    case clientError(HTTPRequestClientError)
    case serverError(HTTPRequestServerError)
    case payloadError(HTTPRequestPayloadError)
}

// TODO:
// * Handle network reachability

final public class NetworkCommunicator: NetworkCommunicatorAPI, Recordable {
    
    public static let shared = Network.Dependencies.default.communicator
    
    private var recorder: Recording?
    
    private let scheduler: ConcurrentDispatchQueueScheduler
    private let session: URLSession
    private let sessionHandler: NetworkCommunicatorSessionHandler
    private let defaultDecoder: NetworkResponseDecoderAPI
    
    init(session: URLSession,
         sessionDelegate: SessionDelegateAPI,
         sessionHandler: NetworkCommunicatorSessionHandler = NetworkCommunicatorSessionHandler(),
         scheduler: ConcurrentDispatchQueueScheduler = ConcurrentDispatchQueueScheduler(qos: .background),
         defaultDecoder: NetworkResponseDecoderAPI = NetworkResponseDecoder.default) {
        self.session = session
        self.sessionHandler = sessionHandler
        self.scheduler = scheduler
        self.defaultDecoder = defaultDecoder
        
        sessionDelegate.delegate = sessionHandler
    }
    
    // MARK: - Recordable
    
    public func use(recorder: Recording) {
        self.recorder = recorder
    }
    
    // MARK: - NetworkCommunicatorAPI
    
    public func perform(request: NetworkRequest) -> Completable {
        return perform(request: request, responseType: EmptyNetworkResponse.self)
    }
    
    public func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable {
        let requestSingle: Single<ResponseType> = perform(request: request)
        return requestSingle.asCompletable()
    }
    
    @available(*, deprecated, message: "Don't use this")
    public func perform<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> Single<Result<ResponseType, ErrorResponseType>> {
        return execute(request: request).decode(with: request.decoder)
    }
    
    public func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        return executeWithDefaultErrorDecoding(request: request).decode(with: request.decoder)
    }
    
    private func executeWithDefaultErrorDecoding(request: NetworkRequest) -> Single<NetworkResponse> {
        return execute(request: request)
            .map { result -> NetworkResponse in
                switch result {
                case .success(let networkResponse):
                    return networkResponse
                case .failure(let networkErrorResponse):
                    let decodedErrorResult: Result<Never, NabuNetworkError> = try request
                        .decoder
                        .decodeFailure(errorResponse: networkErrorResponse)
                    guard case .failure(let errorPayload) = decodedErrorResult else {
                        throw NetworkCommunicatorError.payloadError(.emptyData)
                    }
                    guard let payload = networkErrorResponse.payload else {
                        throw NetworkCommunicatorError.payloadError(.emptyData)
                    }
                    let message = String(data: payload, encoding: .utf8) ?? ""
                    let errorStatusCode = HTTPRequestServerError.badStatusCode(
                        code: networkErrorResponse.response.statusCode,
                        error: errorPayload,
                        message: message
                    )
                    throw NetworkCommunicatorError.serverError(errorStatusCode)
                }
            }
    }
    
    // swiftlint:disable:next function_body_length
    private func execute(request: NetworkRequest) -> Single<Result<NetworkResponse, NetworkErrorResponse>> {
        return Single<Result<NetworkResponse, NetworkErrorResponse>>.create { [weak self] observer -> Disposable in
            let urlRequest = request.URLRequest
            let task = self?.session.dataTask(with: urlRequest) { payload, response, error in
                if let error = error {
                    observer(.error(NetworkCommunicatorError.clientError(.failedRequest(description: error.localizedDescription))))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer(.error(NetworkCommunicatorError.serverError(.badResponse)))
                    return
                }
                if let payload = payload, let responseValue = String(data: payload, encoding: .utf8) {
                    Logger.shared.info(responseValue)
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    observer(.success(.failure(NetworkErrorResponse(response: httpResponse, payload: payload)) ) )
                    return
                }
                observer(.success(.success(NetworkResponse(response: httpResponse, payload: payload))))
            }
            defer {
                task?.resume()
            }
            return Disposables.create {
                task?.cancel()
            }
        }
        .recordErrors(on: recorder, enabled: request.recordErrors)
        .subscribeOn(scheduler)
        .observeOn(scheduler)
    }
    
}

class NetworkCommunicatorSessionHandler: NetworkSessionDelegateAPI {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
        let host = challenge.protectionSpace.host
        Logger.shared.info("Received challenge from \(host)")
        
        #if DISABLE_CERT_PINNING
        completionHandler(.performDefaultHandling, nil)
        #else
        if BlockchainAPI.PartnerHosts.allCases.contains(where: { $0.rawValue == host }) {
            completionHandler(.performDefaultHandling, nil)
        } else {
            CertificatePinner.shared.didReceive(challenge, completion: completionHandler)
        }
        #endif
    }
}
