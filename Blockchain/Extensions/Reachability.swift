//
//  Reachability.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
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

protocol InternentReachabilityAPI: class {
    var canConnect: Bool { get }
}

final class InternentReachability: InternentReachabilityAPI {
    enum ErrorType: Error {
        case interentUnreachable
    }
    
    var canConnect: Bool {
        return Reachability.hasInternetConnection()
    }
}
