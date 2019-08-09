//
//  CryptoAssetQRMetadata.swift
//  PlatformKit
//
//  Created by Alex McGregor on 12/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a URL payload for an asset. The URL typically contains the address,
/// as well as other metadata such as an amount, message, etc. The set of supported metadata
/// can be asset dependent.
public protocol CryptoAssetQRMetadata {
    
    /// The asset's address (e.g. "1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
    var address: String { get }
    
    var amount: String? { get }
    
    /// Converts this URL to an absolute string (e.g. "bitcoin:1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
    var absoluteString: String { get }
    
    /// Render the `absoluteString` with the scheme prefix
    var includeScheme: Bool { get }
    
    /// The asset's scheme (e.g. "bitcoin")
    static var scheme: String { get }
}

extension CryptoAssetQRMetadata {
    public var includeScheme: Bool {
        return false
    }
}
