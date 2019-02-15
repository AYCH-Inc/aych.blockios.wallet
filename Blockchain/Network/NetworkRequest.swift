//
//  NetworkRequest.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

typealias HTTPHeaders = [String: String]

struct NetworkRequest {
    
    enum NetworkError: Error {
        case generic
    }
    
    enum NetworkMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    enum ContentType: String {
        case json = "application/json"
        case formUrlEncoded = "application/x-www-form-urlencoded"
    }
    
    let method: NetworkMethod
    let endpoint: URL
    let headers: HTTPHeaders?
    let contentType: ContentType

    // TODO: modify this to be an Encodable type so that JSON serialization is done in this class
    // vs. having to serialize outside of this class
    let body: Data?

    private let session: URLSession? = {
        guard let session = NetworkManager.shared.session else { return nil }
        return session
    }()
    private var task: URLSessionDataTask?
    
    init(
        endpoint: URL,
        method: NetworkMethod,
        body: Data? = nil,
        headers: HTTPHeaders? = nil,
        contentType: ContentType = .json
    ) {
        self.endpoint = endpoint
        self.method = method
        self.body = body
        self.headers = headers
        self.contentType = contentType
    }

    // swiftlint:disable:next function_body_length
    fileprivate mutating func execute<T: Decodable>(expecting: T.Type, withCompletion: @escaping ((Result<T>, _ responseCode: Int) -> Void)) {
        let responseCode: Int = 0
        
        guard let urlRequest = URLRequest() else {
            withCompletion(.error(nil), responseCode)
            return
        }
        guard let session = session else {
            withCompletion(.error(nil), responseCode)
            return
        }

        // Debugging
        Logger.shared.debug("Sending \(urlRequest.httpMethod ?? "") request to '\(urlRequest.url?.absoluteString ?? "")'")
        if let body = urlRequest.httpBody,
            let bodyString = String(data: body, encoding: .utf8) {
            Logger.shared.debug("Body: \(bodyString)")
        }

        task = session.dataTask(with: urlRequest) { payload, response, error in

            if let error = error {
                withCompletion(.error(HTTPRequestClientError.failedRequest(description: error.localizedDescription)), responseCode)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                withCompletion(.error(HTTPRequestServerError.badResponse), responseCode)
                return
            }

            guard let responseData = payload else {
                withCompletion(.error(HTTPRequestPayloadError.emptyData), responseCode)
                return
            }

            // Debugging
            if let responseString = String(data: responseData, encoding: .utf8) {
                Logger.shared.debug("Response received: \(responseString)")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let errorPayload = try? JSONDecoder().decode(NabuNetworkError.self, from: responseData)
                let errorStatusCode = HTTPRequestServerError.badStatusCode(code: httpResponse.statusCode, error: errorPayload)
                withCompletion(.error(errorStatusCode), httpResponse.statusCode)
                return
            }

            // No need to decode if desired type is Void
            guard T.self != EmptyNetworkResponse.self else {
                let emptyResponse: T = EmptyNetworkResponse() as! T
                withCompletion(.success(emptyResponse), httpResponse.statusCode)
                return
            }

            if let payload = payload, error == nil {
                do {
                    Logger.shared.debug("Received payload: \(String(data: payload, encoding: .utf8) ?? "")")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let final = try decoder.decode(T.self, from: payload)
                    withCompletion(.success(final), httpResponse.statusCode)
                } catch let decodingError {
                    Logger.shared.debug("Payload decoding error: \(decodingError)")
                    withCompletion(.error(HTTPRequestPayloadError.badData), httpResponse.statusCode)
                }
            }
        }
        
        task?.resume()
    }

    private func URLRequest() -> URLRequest? {
        let request: NSMutableURLRequest = NSMutableURLRequest(
            url: endpoint,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30.0
        )

        request.httpMethod = method.rawValue
        request.addValue(HttpHeaderValue.json, forHTTPHeaderField: HttpHeaderField.accept)
        request.addValue(contentType.rawValue, forHTTPHeaderField: HttpHeaderField.contentType)

        if let headers = headers {
            headers.forEach {
                request.addValue($1, forHTTPHeaderField: $0)
            }
        }

        addHttpBody(to: request)

        return request.copy() as? URLRequest
    }

    private func addHttpBody(to request: NSMutableURLRequest) {
        guard let data = body else {
            return
        }

        switch contentType {
        case .json:
            request.httpBody = data
        case .formUrlEncoded:
            if let params = try? JSONDecoder().decode([String: String].self, from: data) {
                request.encode(params: params)
            } else {
                request.httpBody = data
            }
        }
    }
    
    static func POST(url: URL, body: Data?) -> NetworkRequest {
        return self.init(endpoint: url, method: .post, body: body)
    }
    
    static func PUT(url: URL, body: Data?) -> NetworkRequest {
        return self.init(endpoint: url, method: .put, body: body)
    }
    
    static func DELETE(url: URL) -> NetworkRequest {
        return self.init(endpoint: url, method: .delete, body: nil)
    }
}

// MARK: - Rx

extension NetworkRequest {

    static func GET<ResponseType: Decodable>(
        url: URL,
        body: Data? = nil,
        headers: HTTPHeaders? = nil,
        type: ResponseType.Type
    ) -> Single<ResponseType> {
        var request = self.init(endpoint: url, method: .get, body: body, headers: headers)
        return Single.create(subscribe: { observer -> Disposable in
            request.execute(expecting: ResponseType.self, withCompletion: { result, _ in
                switch result {
                case .success(let value):
                    observer(.success(value))
                case .error(let error):
                    observer(.error(error ?? NetworkError.generic))
                }
            })
            return Disposables.create()
        })
    }

    static func POST(
        url: URL,
        body: Data?,
        headers: HTTPHeaders? = nil,
        contentType: ContentType = .json
    ) -> Completable {
        var request = self.init(endpoint: url, method: .post, body: body, headers: headers, contentType: contentType)
        return Completable.create(subscribe: { observer -> Disposable in
            request.execute(expecting: EmptyNetworkResponse.self, withCompletion: { result, _ in
                switch result {
                case .success(_):
                    observer(.completed)
                case .error(let error):
                    observer(.error(error ?? NetworkError.generic))
                }
            })
            return Disposables.create()
        })
    }

    static func POST<ResponseType: Decodable>(
        url: URL,
        body: Data?,
        type: ResponseType.Type,
        headers: HTTPHeaders? = nil,
        contentType: ContentType = .json
    ) -> Single<ResponseType> {
        var request = self.init(endpoint: url, method: .post, body: body, headers: headers, contentType: contentType)
        return Single.create(subscribe: { observer -> Disposable in
            request.execute(expecting: ResponseType.self, withCompletion: { result, _ in
                switch result {
                case .success(let value):
                    observer(.success(value))
                case .error(let error):
                    observer(.error(error ?? NetworkError.generic))
                }
            })
            return Disposables.create()
        })
    }
    
    static func PUT(
        url: URL,
        body: Data?,
        headers: HTTPHeaders? = nil
    ) -> Completable {
        var request = self.init(endpoint: url, method: .put, body: body, headers: headers)
        return Completable.create(subscribe: { observer -> Disposable in
            request.execute(expecting: EmptyNetworkResponse.self, withCompletion: { result, _ in
                switch result {
                case .success(_):
                    observer(.completed)
                case .error(let error):
                    observer(.error(error ?? NetworkError.generic))
                }
            })
            return Disposables.create()
        })
    }

    static func PUT<ResponseType: Decodable>(
        url: URL,
        body: Data?,
        type: ResponseType.Type,
        headers: HTTPHeaders? = nil
    ) -> Single<ResponseType> {
        var request = self.init(endpoint: url, method: .put, body: body, headers: headers)
        return Single.create(subscribe: { observer -> Disposable in
            request.execute(expecting: ResponseType.self, withCompletion: { result, _ in
                switch result {
                case .success(let value):
                    observer(.success(value))
                case .error(let error):
                    observer(.error(error ?? NetworkError.generic))
                }
            })
            return Disposables.create()
        })
    }
}

extension NSMutableURLRequest {

    func encode(params: [String : String]) {
        let encodedParamsArray = params.map { keyPair -> String in
            let (key, value) = keyPair
            return "\(key)=\(self.percentEscapeString(value))"
        }
        self.httpBody = encodedParamsArray.joined(separator: "&").data(using: .utf8)
    }

    private func percentEscapeString(_ stringToEscape: String) -> String {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._* ")
        return stringToEscape
            .addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)?
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil) ?? stringToEscape
    }
}
