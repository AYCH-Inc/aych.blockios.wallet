//
//  Reachability+API.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

extension Reachability {

    /// Checks if the device has internet connectivity
    @objc static func hasInternetConnection() -> Bool {
        let reachability = Reachability.forInternetConnection()
        guard reachability?.currentReachabilityStatus() != NotReachable else {
            Logger.shared.info("No internet connection.")
            return false
        }
        return true
    }
}

protocol InternetReachabilityAPI: class {
    var canConnect: Bool { get }
}

public final class InternetReachability: InternetReachabilityAPI {
    public enum ErrorType: Error {
        case internetUnreachable
    }
    
    var canConnect: Bool {
        return Reachability.hasInternetConnection()
    }
    public init() {}
}
