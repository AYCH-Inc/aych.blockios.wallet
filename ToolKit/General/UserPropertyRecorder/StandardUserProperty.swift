//
//  StandardUserProperty.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Can be used to keep any key-value that doesn't require obfuscation
public struct StandardUserProperty: UserProperty {    
    public let key: UserPropertyKey
    public let value: String
    public let truncatesValueIfNeeded: Bool
    
    public init(key: Key, value: String, truncatesValueIfNeeded: Bool = false) {
        self.key = key
        self.value = value
        self.truncatesValueIfNeeded = truncatesValueIfNeeded
    }
}

extension StandardUserProperty: Hashable {
    public static func == (lhs: StandardUserProperty, rhs: StandardUserProperty) -> Bool {
        return lhs.key.rawValue == rhs.key.rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key.rawValue)
    }
}

extension StandardUserProperty {
    
    /// A key for which a hashed user property is being recorded
    public enum Key: String, UserPropertyKey {
        case walletCreationDate = "creation_date"
        case kycCreationDate = "kyc_creation_date"
        case kycUpdateDate = "kyc_updated_date"
        case kycLevel = "kyc_level"
    }
}
