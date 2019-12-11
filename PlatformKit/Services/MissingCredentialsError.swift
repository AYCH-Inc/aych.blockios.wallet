//
//  MissingCredentialsError.swift
//  PlatformKit
//
//  Created by Daniel Huri on 21/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// An error thrown for missing credentials
public enum MissingCredentialsError: Error {
    
    /// Cannot send request because of missing GUID
    case guid
        
    /// Cannot send request because of a missing session token
    case sessionToken
    
    /// Cannot send request because of a missing shared key
    case sharedKey
}
