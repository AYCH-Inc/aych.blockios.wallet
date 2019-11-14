//
//  NetworkCommunicator.swift
//  Blockchain
//
//  Created by Jack on 07/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

#if DEBUG
fileprivate var DISABLE_CERT_PINNING: Bool = false
#endif

public protocol NetworkCommunicatorAPI {
    func perform(request: NetworkRequest) -> Completable
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable
    func perform<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> Single<Result<ResponseType, ErrorResponseType>>
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType>
    func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType>
}

// TODO:
// * Handle network reachability

final public class NetworkCommunicator: NetworkCommunicatorAPI, AnalyticsEventRecordable {
    
    public static let shared = Network.Dependencies.default.communicator
    
    private var eventRecorder: AnalyticsEventRecording?
    
    private let scheduler: ConcurrentDispatchQueueScheduler
    private let session: URLSession
    private let sessionHandler: NetworkCommunicatorSessionHandler
    
    init(session: URLSession,
         sessionDelegate: SessionDelegateAPI,
         sessionHandler: NetworkCommunicatorSessionHandler = NetworkCommunicatorSessionHandler(),
         scheduler: ConcurrentDispatchQueueScheduler = ConcurrentDispatchQueueScheduler(qos: .background)) {
        self.session = session
        self.sessionHandler = sessionHandler
        self.scheduler = scheduler
        
        sessionDelegate.delegate = sessionHandler
        
        #if DEBUG
            DISABLE_CERT_PINNING = true
        #endif
    }
    
    // MARK: - Recordable
    
    public func use(eventRecorder: AnalyticsEventRecording) {
        self.eventRecorder = eventRecorder
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
        return execute(request: request)
            .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
                error.analyticsEvent(for: request) { serverErrorResponse in
                    request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
                }
            }
            .mapRawServerError()
            .decode(with: request.decoder)
    }
    
    public func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType> {
        return perform(request: request)
    }
    
    public func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        return execute(request: request)
            .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
                error.analyticsEvent(for: request) { serverErrorResponse in
                    request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
                }
            }
            .mapRawServerError()
            .decode(with: request.decoder)
    }
    
    // swiftlint:disable:next function_body_length
    private func execute(request: NetworkRequest) -> Single<
        Result<ServerResponse, NetworkCommunicatorError>
    > {
        return Single<Result<ServerResponse, NetworkCommunicatorError>>.create { [weak self] observer -> Disposable in
            let urlRequest = request.URLRequest
            Logger.shared.debug("urlRequest.url: \(urlRequest.url)")
            let task = self?.session.dataTask(with: urlRequest) { payload, response, error in
                if let error = error {
                    observer(.success(.failure(NetworkCommunicatorError.clientError(.failedRequest(description: error.localizedDescription)))))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer(.success(.failure(NetworkCommunicatorError.serverError(.badResponse))))
                    return
                }
                if let payload = payload, let responseValue = String(data: payload, encoding: .utf8) {
                    Logger.shared.debug(responseValue)
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    observer(.success(.failure(NetworkCommunicatorError.rawServerError(ServerErrorResponse(response: httpResponse, payload: payload)))))
                    return
                }
                observer(.success(.success(ServerResponse(response: httpResponse, payload: payload))))
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

class NetworkCommunicatorSessionHandler: NetworkSessionDelegateAPI {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
        #if DEBUG
        guard !DISABLE_CERT_PINNING else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        #endif
        
        let host = challenge.protectionSpace.host
        Logger.shared.info("Received challenge from \(host)")
        
        if BlockchainAPI.PartnerHosts.allCases.contains(where: { $0.rawValue == host }) {
            completionHandler(.performDefaultHandling, nil)
        } else {
            CertificatePinner.shared.didReceive(challenge, completion: completionHandler)
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Result<ServerResponse, NetworkCommunicatorError> {
    fileprivate func recordErrors(on recorder: AnalyticsEventRecording?, request: NetworkRequest, errorMapper: @escaping (NetworkRequest, NetworkCommunicatorError) -> AnalyticsEvent?) -> Single<Element> {
        guard request.recordErrors else { return self }
        return self.do(onSuccess: { result in
                guard case .failure(let error) = result else {
                    return
                }
                guard let event = errorMapper(request, error) else {
                    return
                }
                recorder?.record(event: event)
            })
            .do(onError: { error in
                guard let error = error as? NetworkCommunicatorError else {
                    return
                }
                guard let event = errorMapper(request, error) else {
                    return
                }
                recorder?.record(event: event)
            })
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Result<ServerResponse, NetworkCommunicatorError> {
    fileprivate func mapRawServerError() -> Single<Result<ServerResponse, ServerErrorResponse>> {
        return map { result -> Result<ServerResponse, ServerErrorResponse> in
            switch result {
            case .success(let networkResponse):
                return .success(networkResponse)
            case .failure(let error):
                guard case .rawServerError(let serverErrorResponse) = error else {
                    throw error
                }
                return .failure(serverErrorResponse)
            }
        }
    }
}
