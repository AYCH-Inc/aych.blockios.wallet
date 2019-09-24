//
//  RequestBuilder.swift
//  PlatformKit
//
//  Created by Jack on 20/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class RequestBuilder {
    
    private var defaultComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = networkConfig.apiScheme
        urlComponents.host = networkConfig.apiHost
        return urlComponents
    }
    
    private let networkConfig: Network.Config
    
    public init(networkConfig: Network.Config) {
        self.networkConfig = networkConfig
    }
    
    // MARK: - GET
    
    public func get(path components: [String] = [],
                    parameters: [URLQueryItem] = [],
                    headers: HTTPHeaders? = nil,
                    contentType: NetworkRequest.ContentType = .json,
                    decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder.default,
                    recordErrors: Bool = false) -> NetworkRequest? {
        return get(
            path: RequestBuilder.path(from: components),
            parameters: parameters,
            headers: headers,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }
    
    public func get(path: String,
                    parameters: [URLQueryItem] = [],
                    headers: HTTPHeaders? = nil,
                    contentType: NetworkRequest.ContentType = .json,
                    decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder.default,
                    recordErrors: Bool = false) -> NetworkRequest? {
        return buildRequest(
            method: .get,
            path: path,
            parameters: parameters,
            headers: headers,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }
    
    // MARK: - POST
    
    public func post(path components: [String] = [],
                     parameters: [URLQueryItem] = [],
                     body: Data? = nil,
                     headers: HTTPHeaders? = nil,
                     contentType: NetworkRequest.ContentType = .json,
                     decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder.default,
                     recordErrors: Bool = false) -> NetworkRequest? {
        return post(
            path: RequestBuilder.path(from: components),
            parameters: parameters,
            body: body,
            headers: headers,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }
    
    public func post(path: String,
                     parameters: [URLQueryItem] = [],
                     body: Data? = nil,
                     headers: HTTPHeaders? = nil,
                     contentType: NetworkRequest.ContentType = .json,
                     decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder.default,
                     recordErrors: Bool = false) -> NetworkRequest? {
        return buildRequest(
            method: .post,
            path: path,
            parameters: parameters,
            body: body,
            headers: headers,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }
    
    public static func path(from components: [String] = []) -> String {
        return components.reduce(into: "") { path, component in
            path += "/\(component)"
        }
    }
    
    // MARK: - Private methods
    
    private func buildRequest(method: NetworkRequest.NetworkMethod,
                              path: String,
                              parameters: [URLQueryItem] = [],
                              body: Data? = nil,
                              headers: HTTPHeaders? = nil,
                              contentType: NetworkRequest.ContentType = .json,
                              decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder.default,
                              recordErrors: Bool = false) -> NetworkRequest? {
        guard let url = buildURL(path: path, parameters: parameters) else {
            return nil
        }
        return NetworkRequest(
            endpoint: url,
            method: method,
            body: body,
            headers: headers,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }
    
    private func buildURL(path: String, parameters: [URLQueryItem] = []) -> URL? {
        var components = defaultComponents
        components.path = path
        components.queryItems = parameters
        return components.url
    }
}
