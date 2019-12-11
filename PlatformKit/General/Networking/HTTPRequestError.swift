//
//  HTTPRequestError.swift
//  Blockchain
//
//  Created by Maurice A. on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol HTTPRequestError: Error {
    var debugDescription: String { get }
}

// TODO: add more specific client errors based on the error returned by URLSession data task
// NOTE: the description argument refers to the localized description returned by URLSession data task.
public enum HTTPRequestClientError: HTTPRequestError {
    case reachability
    case failedRequest(description: String)
    public var debugDescription: String {
        switch self {
        case .failedRequest(let description): return description
        case .reachability: return "Internet unreachable"
        }
    }
}
public enum HTTPRequestServerError: HTTPRequestError {
    case badResponse, badStatusCode(code: Int, error: Error?, message: String?)
    public var debugDescription: String {
        switch self {
        case .badResponse: return "Bad response."
        case .badStatusCode(let code, _, let message): return "The server returned a bad response: \(code). Message: \(message ?? "")"
        }
    }
    
    public var code: Int? {
        switch self {
        case .badResponse:
            return nil
        case .badStatusCode(code: let code, error: _, message: _):
            return code
        }
    }
    
    public var nabuError: NabuNetworkError? {
        switch self {
        case .badStatusCode(code: _, error: let value, message: _):
            guard let nabuError = value as? NabuNetworkError else { return nil }
            return nabuError
        case .badResponse:
            return nil
        }
    }
    
}

// NOTE: in future cases, we may want to allow empty payloads, but this is currently not applicable for the KYC flow.
public enum HTTPRequestPayloadError: HTTPRequestError {
    case badData(rawPayload: String)
    case emptyData
    case invalidMimeType(type: String)
    
    public var debugDescription: String {
        switch self {
        case .badData: return "The data returned by the server was bad."
        case .emptyData: return "The data returned by the server was empty."
        case .invalidMimeType(let type): return "The server returned an invalid MIME type: \(type)."
        }
    }
}
