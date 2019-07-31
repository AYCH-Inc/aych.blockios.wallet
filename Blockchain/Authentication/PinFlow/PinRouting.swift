//
//  PinRouting.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct PinRouting {
    
    /// Any possible routing error along displaying / dismissing the PIN flow
    enum FlowError: Error {
        /// Navigation controller is not initialized for some reason
        case navigationControllerIsNotInitialized
    }
    
    /// The flow of the pin
    enum Flow {
        
        /// The origin of the flow
        enum Origin {
            
            /// In-app state that requires the user to re-authenticate to enable a feature
            case foreground
            
            /// Background app state that requires the user's authentication to access the app
            case background
        }
        
        /// Change old pin code to a new one
        case change(logoutRouting: RoutingType.Logout)
        
        /// Creation of a new pin code where none existed before
        case create
        
        /// Authentication flow: upon entering foreground
        case authenticate(from: Origin, logoutRouting: RoutingType.Logout)
        
        /// Enable biometrics
        case enableBiometrics(logoutRouting: RoutingType.Logout)
        
        /// Returns `true` if the flow is `create`
        var isCreate: Bool {
            switch self {
            case .create:
                return true
            default:
                return false
            }
        }
        
        // Returns `true` for change pin flow
        var isChange: Bool {
            switch self {
            case .change:
                return true
            default:
                return false
            }
        }
        
        /// Returns `true` for login authnetication
        var isLoginAuthentication: Bool {
            switch self {
            case .authenticate(from: let origin, logoutRouting: _) where origin == .background:
                return true
            default:
                return false
            }
        }
        
        /// Returns the origin of the pin flow
        var origin: Origin {
            switch self {
            case .authenticate(from: let origin, logoutRouting: _):
                return origin
            default:
                return .foreground
            }
        }
        
        // Returns logout routing if configured for flow
        var logoutRouting: RoutingType.Logout? {
            switch self {
            case .authenticate(from: _, logoutRouting: let routing):
                return routing
            case .change(logoutRouting: let routing):
                return routing
            case .enableBiometrics(logoutRouting: let routing):
                return routing
            case .create:
                return nil
            }
        }
    }
    
    struct RoutingType {
        typealias Forward = (RoutingType.Input) -> Void
        typealias Backward = () -> Void
        typealias Logout = () -> Void
        
        enum Input {
            case authentication(pinDecryptionKey: String)
            case pin(value: Pin)
            case none
            
            var pin: Pin? {
                switch self {
                case .pin(value: let pin):
                    return pin
                default:
                    return nil
                }
            }
            
            var pinDecryptionKey: String? {
                switch self {
                case .authentication(pinDecryptionKey: let key):
                    return key
                default:
                    return nil
                }
            }
        }
    }
}

// MARK: CustomDebugStringConvertible

extension PinRouting.Flow: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .authenticate(from: let origin, logoutRouting: _):
            switch origin {
            case .foreground:
                return "authentication from foreground"
            case .background:
                return "authentication from background"
            }
        case .change:
            return "change pin"
        case .enableBiometrics:
            return "enable biometrics"
        case .create:
            return "create a new pin"
        }
    }
}
