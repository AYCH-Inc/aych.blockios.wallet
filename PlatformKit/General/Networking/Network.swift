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
            apiCode: "1770d5d9-bcea-4d28-ad21-6cbd5be018a8" // TODO: is this the correct value?
        )
        
        static let retailConfig: Config = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.retailCoreUrl,
            apiCode: "1770d5d9-bcea-4d28-ad21-6cbd5be018a8"
        )
    }
    
    public struct Dependencies {
        // TODO:
        // * This should be private, public until we can re-write our old network code
        public let blockchainAPIConfig: Config
        public let session: URLSession
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
            return Dependencies(
                blockchainAPIConfig: blockchainAPIConfig,
                session: session,
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
            return Dependencies(
                blockchainAPIConfig: blockchainAPIConfig,
                session: session,
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
