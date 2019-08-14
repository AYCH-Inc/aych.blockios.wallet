//
//  NetworkManager.swift
//  Blockchain
//
//  Created by Maurice A. on 4/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public struct Network {
    public struct Dependencies {
        let session: URLSession
        let sessionConfiguration: URLSessionConfiguration
        let sessionDelegate: SessionDelegateAPI
        public let communicator: NetworkCommunicatorAPI
        
        public static let `default`: Dependencies = {
            let sessionConfiguration = URLSessionConfiguration.default
            if let userAgent = NetworkManager.userAgent {
                sessionConfiguration.httpAdditionalHeaders = [HttpHeaderField.userAgent: userAgent]
            }
            if #available(iOS 11.0, *) {
                sessionConfiguration.waitsForConnectivity = true
            }
            
            let sessionDelegate = SessionDelegate()
            
            let session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
            
            let communicator = NetworkCommunicator(session: session)
            
            return Dependencies(
                session: session,
                sessionConfiguration: sessionConfiguration,
                sessionDelegate: sessionDelegate,
                communicator: communicator
            )
        }()
    }
}

protocol NetworkManagerDelegateAPI: class {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler)
}

protocol SessionDelegateAPI: class, URLSessionDelegate {
    var delegate: NetworkManagerDelegateAPI? { get set }
}

private class SessionDelegate: NSObject, SessionDelegateAPI {
    public weak var delegate: NetworkManagerDelegateAPI?
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
        delegate?.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
}

public typealias AuthChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void

public typealias URLParameters = [String: Any]

public typealias URLHeaders = [String: String]

/**
 Manages network related tasks such as requests and sessions.
 # Usage
 TBD
 - Author: Maurice Achtenhagen
 - Copyright: Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
 */

@available(*, deprecated, message: "Don't use this, prefer `NetworkCommunicator`")
@objc open class NetworkManager: NSObject, NetworkManagerDelegateAPI {

    /// Parameter encoding for networking
    public enum Encoding {
        
        /// JSON encoding
        case json
        
        /// URL encoding
        case url
        
        var networkEncoding: NetworkRequest.ContentType {
            switch self {
            case .json:
                return NetworkRequest.ContentType.json
            case .url:
                return NetworkRequest.ContentType.formUrlEncoded
            }
        }
    }
        
    // MARK: - Properties

    /// The instance variable used to access functions of the `NetworkManager` class.
    public static let shared = NetworkManager()

    /// Default unknown network error
    static let unknownNetworkError = NSError(domain: "NetworkManagerDomain", code: -1, userInfo: nil)

    // TODO: remove once Swift migration is complete
    /// Objective-C compatible class function
    @objc public class func sharedInstance() -> NetworkManager {
        return NetworkManager.shared
    }
    
    // TODO: Make this private
    @objc public let session: URLSession
    
    private let sessionConfiguration: URLSessionConfiguration
    private let sessionDelegate: SessionDelegateAPI
    private let communicator: NetworkCommunicatorAPI
    
    // MARK: - Initialization

    public init(dependencies: Network.Dependencies = Network.Dependencies.default) {
        
        self.sessionDelegate = dependencies.sessionDelegate
        self.sessionConfiguration = dependencies.sessionConfiguration
        self.session = dependencies.session
        self.communicator = dependencies.communicator
        
        super.init()
        
        self.sessionDelegate.delegate = self
        
        disableUIWebViewCaching()
        persistServerSessionIDForNewUIWebViews()
    }
    
    /// Performs a POST API call.
    /// Using a dictionary as data.
    /// It performs the request and decode it in background.
    /// It's the caller's responsibility to observe the result on whichever queue is needed.
    /// - Parameters:
    ///   - url: The full url for the endpoint
    ///   - headers: Headers to be sent in form of key-value. default value: `nil`
    ///   - parameters: The dictionary parameters. default value: `[:]`
    ///   - decodableType: The expected type of the response
    ///   - encoding: The expected type of the parameter encoding, e.g JSON, URL
    ///   - onErrorJustReturn: In case we still want to return regularly for an error
    /// - Returns: The response wrapped in a Single
    @available(*, deprecated, message: "Don't use this")
    public func post<T: Decodable>(_ url: String,
                                   headers: URLHeaders? = nil,
                                   parameters: URLParameters = [:],
                                   decodeTo decodableType: T.Type,
                                   encoding: Encoding = .url,
                                   onErrorJustReturn: Bool = false) -> Single<T> {
        return request(.post,
                       url: url,
                       headers: headers,
                       parameters: parameters,
                       decodeTo: decodableType,
                       encoding: encoding,
                       onErrorJustReturn: onErrorJustReturn)
    }
    
    // MARK: - Get
    
    /// Performs a GET API call.
    /// It performs the request and decode it in background.
    /// It's the caller's responsibility to observe the result on whichever queue is needed.
    /// - Parameters:
    ///   - url: The full url for the endpoint
    ///   - headers: Headers to be sent in form of key-value. default value: `nil`
    ///   - decodableType: The expected type of the response
    ///   - encoding: The expected type of the parameter encoding, e.g JSON, URL
    ///   - onErrorJustReturn: In case we still want to return regularly for an error
    /// - Returns: The response wrapped in a Single
    @available(*, deprecated, message: "Don't use this")
    public func get<T: Decodable>(_ url: String,
                                  headers: URLHeaders? = nil,
                                  decodeTo decodableType: T.Type,
                                  encoding: Encoding = .url,
                                  onErrorJustReturn: Bool = false) -> Single<T> {
        return request(.get,
                       url: url,
                       headers: headers,
                       decodeTo: decodableType,
                       encoding: encoding,
                       onErrorJustReturn: onErrorJustReturn)
    }
    
    // MARK: - Put
    
    /// Performs a PUT API call.
    /// Using `Encodable` as data.
    /// It performs the request and decode it in background.
    /// It's the caller's responsibility to observe the result on whichever queue is needed.
    /// - Parameters:
    ///   - url: The full url for the endpoint
    ///   - headers: Headers to be sent in form of key-value. default value: `nil`
    ///   - data: An encodable data object
    ///   - decodableType: The expected type of the response
    ///   - encoding: The expected type of the parameter encoding, e.g JSON, URL
    ///   - onErrorJustReturn: In case we still want to return regularly for an error
    /// - Returns: The response wrapped in a Single
    @available(*, deprecated, message: "Don't use this")
    public func put<T: Decodable>(_ url: String,
                                  headers: URLHeaders? = nil,
                                  data: Encodable,
                                  decodeTo decodableType: T.Type,
                                  encoding: Encoding = .url,
                                  onErrorJustReturn: Bool = false) -> Single<T> {
        return put(url,
                   headers: headers,
                   parameters: data.dictionary as! [String : String],
                   decodeTo: decodableType,
                   encoding: encoding,
                   onErrorJustReturn: onErrorJustReturn)
    }
    
    /// Performs a PUT API call.
    /// Using dictionary as data.
    /// It performs the request and decode it in background.
    /// It's the caller's responsibility to observe the result on whichever queue is needed.
    /// - Parameters:
    ///   - url: The full url for the endpoint
    ///   - headers: Headers to be sent in form of key-value. default value: `nil`
    ///   - parameters: The dictionary parameters. default value: `[:]`.
    ///   - decodableType: The expected type of the response
    ///   - encoding: The expected type of the parameter encoding, e.g JSON, URL
    ///   - onErrorJustReturn: In case we still want to return regularly for an error
    @available(*, deprecated, message: "Don't use this")
    public func put<T: Decodable>(_ url: String,
                                  headers: URLHeaders? = nil,
                                  parameters: URLParameters = [:],
                                  decodeTo decodableType: T.Type,
                                  encoding: Encoding = .url,
                                  onErrorJustReturn: Bool = false) -> Single<T> {
        return request(.put,
                       url: url,
                       headers: headers,
                       parameters: parameters,
                       decodeTo: decodableType,
                       encoding: encoding,
                       onErrorJustReturn: onErrorJustReturn)
    }
    
    // MARK: - Delete
    
    /// Performs a DELETE API call.
    /// It performs the request and decode it in background.
    /// It's the caller's responsibility to observe the result on whichever queue is needed.
    /// - Parameters:
    ///   - url: The full url for the endpoint
    ///   - headers: Headers to be sent in form of key-value. default value: `nil`
    ///   - decodableType: The expected type of the response
    ///   - encoding: The expected type of the parameter encoding, e.g JSON, URL
    ///   - onErrorJustReturn: In case we still want to return regularly for an error
    @available(*, deprecated, message: "Don't use this")
    public func delete<T: Decodable>(_ url: String,
                                     headers: URLHeaders? = nil,
                                     decodeTo decodableType: T.Type,
                                     encoding: Encoding = .url,
                                     onErrorJustReturn: Bool = false) -> Single<T> {
        return request(.delete,
                       url: url,
                       headers: headers,
                       decodeTo: decodableType,
                       encoding: encoding,
                       onErrorJustReturn: onErrorJustReturn)
    }
    
    // MARK: - Generic Request
    
    /// Privately used to perform any kind of REST network request logic.
    private func request<T: Decodable>(_ method: HTTPMethod,
                                       url: String,
                                       headers: URLHeaders? = nil,
                                       parameters: URLParameters? = nil,
                                       decodeTo decodableType: T.Type,
                                       encoding: Encoding,
                                       onErrorJustReturn: Bool = false) -> Single<T> {
        guard let url = URL(string: url) else {
            return Single.error(NSError())
        }
        let body: Data? = encode(parameters, encoding: encoding)
        let request = NetworkRequest(
            endpoint: url,
            method: method.networkRequestMethod,
            body: body,
            headers: headers,
            contentType: encoding.networkEncoding
        )
        return communicator.perform(request: request)
    }
    
    // MARK: - Old networking
    
    @available(*, deprecated, message: "Don't use this")
    public func request<ResponseType: Decodable>(
        _ request: URLRequest,
        responseType: ResponseType.Type
    ) -> Single<ResponseType> {
        return communicator.perform(request: request)
    }
    
    /// Performs a network request and returns an Observable emitting the HTTPURLResponse along with the
    /// decoded response data. The response data will be attempted to be decoded as a JSON
    ///
    /// - Parameters:
    ///   - url: the URL for the request (e.g. "http://blockchain.info/uuid-generator?n=3")
    ///   - method: the HTTP method
    ///   - parameters: the parameters for the request
    /// - Returns: a Single returning the HTTPURLResponse and the decoded response data
    @available(*, deprecated, message: "Don't use this")
    open func requestJson(
        _ url: String,
        method: HTTPMethod,
        parameters: URLParameters? = nil,
        headers: URLHeaders? = nil
    ) -> Single<(HTTPURLResponse, JSON)> {
        guard let url = URL(string: url) else {
            return Single.error(NSError())
        }
        var body: Data? = nil
        if let parameters = parameters {
            body = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }
        let request = NetworkRequest(
            endpoint: url,
            method: method.networkRequestMethod,
            body: body,
            headers: headers,
            contentType: NetworkRequest.ContentType.formUrlEncoded
        )
        return communicator.perform(request: request)
    }

    // MARK: - NetworkManagerDelegateAPI

    // TODO: find place to put UIApplication.shared.isNetworkActivityIndicatorVisible

    internal func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
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

    // MARK: - Private Functions

    fileprivate func persistServerSessionIDForNewUIWebViews() {
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.cookieAcceptPolicy = .always
    }

    fileprivate func disableUIWebViewCaching() {
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
    }
    
    private func encode(_ parameters: URLParameters?, encoding: Encoding) -> Data? {
        guard let parameters = parameters else { return nil }
        let body: Data?
        switch encoding {
        case .json:
            body = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        case .url:
            body = ParameterEncoder(parameters).encoded
        }
        return body
    }
}

extension HTTPMethod {
    var networkRequestMethod: NetworkRequest.NetworkMethod {
        switch self {
        case .get:
            return NetworkRequest.NetworkMethod.get
        case .post:
            return NetworkRequest.NetworkMethod.post
        case .put:
            return NetworkRequest.NetworkMethod.put
        case .patch:
            return NetworkRequest.NetworkMethod.patch
        case .delete:
            return NetworkRequest.NetworkMethod.delete
        }
    }
}

extension Data {
    func decode<T: Decodable>(to type: T.Type) throws -> T {
        let decoded: T
        do {
            decoded = try JSONDecoder().decode(type, from: self)
        } catch {
            print(error)
            throw error
        }
        return decoded
    }
}

extension Encodable {
    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any] ?? [:]
    }
}

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

extension Bool {
    var encoded: String {
        return self ? "true" : "false"
    }
}

// TODO:
// * Remove this, this code is from Alamofire

//  Copyright (c) 2014-2018 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@available(*, deprecated, message: "Don't use this, this will be removed")
public class ParameterEncoder {
    
    public var encoded: Data? {
        return encode(parameters)
    }
    
    private let parameters: [String: Any]
    
    public init(_ parameters: [String: Any]) {
        self.parameters = parameters
    }
    
    private func encode(_ parameters: [String: Any]) -> Data? {
        let encodedParameters = query(parameters)
        return encodedParameters.data(using: .utf8, allowLossyConversion: false)
    }
    
    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    /// Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
    ///
    /// - parameter key:   The key of the query component.
    /// - parameter value: The value of the query component.
    ///
    /// - returns: The percent-escaped, URL encoded query string components.
    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: key, value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape(value.boolValue.encoded) ))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape(bool.encoded)))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }

    /// Returns a percent-escaped string following RFC 3986 for a query string key or value.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    ///
    /// - parameter string: The string to be percent-escaped.
    ///
    /// - returns: The percent-escaped string.
    private func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        var escaped = ""
        
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        
        return escaped
    }
}
