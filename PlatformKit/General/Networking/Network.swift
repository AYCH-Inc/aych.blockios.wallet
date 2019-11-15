//
//  Network.swift
//  PlatformKit
//
//  Created by Jack on 22/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

@available(*, deprecated, message: "Don't use this. If you're reaching for this you're doing something wrong.")
@objc public class NetworkDependenciesObjc: NSObject {
    @objc public let session: URLSession = Network.Dependencies.default.session
    
    public static let shared = NetworkDependenciesObjc()
    
    @objc public class func sharedInstance() -> NetworkDependenciesObjc {
        return NetworkDependenciesObjc.shared
    }
}

public struct Network {
    
    public struct Config {
        public let apiScheme: String
        public let apiHost: String
        public let apiCode: String
        
        static let defaultConfig: Config = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.apiHost,
            apiCode: BlockchainAPI.Parameters.apiCode
        )
        
        static let retailConfig: Config = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.retailCoreUrl,
            apiCode: BlockchainAPI.Parameters.apiCode
        )
        
        static let walletConfig: Config = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.walletHost,
            apiCode: BlockchainAPI.Parameters.apiCode
        )
    }
    
    public struct Dependencies {
        // TODO:
        // * This should be private, public until we can re-write our old network code
        public let blockchainAPIConfig: Config
        public let session: URLSession
        public let requestBuilder: RequestBuilder
        
        let sessionConfiguration: URLSessionConfiguration
        let sessionDelegate: SessionDelegateAPI
        
        public let communicator: NetworkCommunicatorAPI & AnalyticsEventRecordable
        
        public static let `default`: Dependencies = {
            let blockchainAPIConfig = Config.defaultConfig
            let sessionConfiguration = URLSessionConfiguration.default
            if let userAgent = Network.userAgent {
                sessionConfiguration.httpAdditionalHeaders = [HttpHeaderField.userAgent: userAgent]
            }
            if #available(iOS 11.0, *) {
                sessionConfiguration.waitsForConnectivity = true
            }
            let sessionDelegate = SessionDelegate()
            let session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
            let communicator = NetworkCommunicator(session: session, sessionDelegate: sessionDelegate)
            let requestBuilder = RequestBuilder(networkConfig: blockchainAPIConfig)
            return Dependencies(
                blockchainAPIConfig: blockchainAPIConfig,
                session: session,
                requestBuilder: requestBuilder,
                sessionConfiguration: sessionConfiguration,
                sessionDelegate: sessionDelegate,
                communicator: communicator
            )
        }()
        
        public static let wallet: Dependencies = {
            let blockchainAPIConfig = Config.walletConfig
            let sessionConfiguration = URLSessionConfiguration.default
            if let userAgent = Network.userAgent {
                sessionConfiguration.httpAdditionalHeaders = [HttpHeaderField.userAgent: userAgent]
            }
            if #available(iOS 11.0, *) {
                sessionConfiguration.waitsForConnectivity = true
            }
            let sessionDelegate = SessionDelegate()
            let session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
            let communicator = NetworkCommunicator(session: session, sessionDelegate: sessionDelegate)
            let requestBuilder = RequestBuilder(networkConfig: blockchainAPIConfig)
            return Dependencies(
                blockchainAPIConfig: blockchainAPIConfig,
                session: session,
                requestBuilder: requestBuilder,
                sessionConfiguration: sessionConfiguration,
                sessionDelegate: sessionDelegate,
                communicator: communicator
            )
        }()
        
        public static let retail: Dependencies = {
            let blockchainAPIConfig = Config.retailConfig
            let sessionConfiguration = URLSessionConfiguration.default
            if let userAgent = Network.userAgent {
                sessionConfiguration.httpAdditionalHeaders = [HttpHeaderField.userAgent: userAgent]
            }
            if #available(iOS 11.0, *) {
                sessionConfiguration.waitsForConnectivity = true
            }
            let sessionDelegate = SessionDelegate()
            let session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
            let communicator = NetworkCommunicator(session: session, sessionDelegate: sessionDelegate)
            let requestBuilder = RequestBuilder(networkConfig: blockchainAPIConfig)
            return Dependencies(
                blockchainAPIConfig: blockchainAPIConfig,
                session: session,
                requestBuilder: requestBuilder,
                sessionConfiguration: sessionConfiguration,
                sessionDelegate: sessionDelegate,
                communicator: communicator
            )
        }()
    }
    
    static var userAgent: String? {
        let systemVersion = UIDevice.current.systemVersion
        let modelName = UIDevice.current.model
        guard
            let version = Bundle.applicationVersion,
            let build = Bundle.applicationBuildVersion else {
                return nil
        }
        let versionAndBuild = String(format: "%@ b%@", version, build)
        return String(format: "Blockchain-iOS/%@ (iOS/%@; %@)", versionAndBuild, systemVersion, modelName)
    }
}

protocol NetworkSessionDelegateAPI: class {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler)
}

protocol SessionDelegateAPI: class, URLSessionDelegate {
    var delegate: NetworkSessionDelegateAPI? { get set }
}

private class SessionDelegate: NSObject, SessionDelegateAPI {
    public weak var delegate: NetworkSessionDelegateAPI?
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
        delegate?.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
}

public typealias AuthChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void

public typealias URLParameters = [String: Any]

public typealias URLHeaders = [String: String]

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

extension Bool {
    var encoded: String {
        return self ? "true" : "false"
    }
}
