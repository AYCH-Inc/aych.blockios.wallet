//
//  UserProperty.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// A key for which any user property is being recorded
public protocol UserPropertyKey {
    var rawValue: String { get }
}

/// The user property protocol defines the
public protocol UserProperty {
        
    /// The key for which the property should be recorded
    var key: UserPropertyKey { get }
    
    /// The value corresponding to the key
    var value: String { get }
    
    /// Truncates the value if needed
    /// Should be typically used when the sent value's length might exceed the allowed threshold
    var truncatesValueIfNeeded: Bool { get }
}
