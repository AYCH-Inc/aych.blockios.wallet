//
//  WalletPayload.swift
//  PlatformKit
//
//  Created by Daniel Huri on 27/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The wallet payload as it is returned by the server
public struct WalletPayload {
    
    /// Possible errors for payload
    public enum MappingError: Error {
        
        /// Missing raw string
        case missingRawInput
        
        /// Cannot convert the raw input to `Data`
        case dataConversionFailure
    }
        
    public let bpkdf2IterationCount: Int
    public let version: Int
    public let payload: String
    
    /// Returns `self` as string (JS requirements)
    var stringRepresentation: String? {
        return try? encodeToString(encoding: .utf8)
    }
}

// MARK: - Codable

extension WalletPayload: Codable {
    
    enum CodingKeys: String, CodingKey {
        case bpkdf2IterationCount = "pbkdf2_iterations"
        case version
        case payload
    }
    
    public init(string: String?) throws {
        guard let string = string else { throw MappingError.missingRawInput }
        guard let data = string.data(using: .utf8) else { throw MappingError.dataConversionFailure }
        self = try data.decode(to: WalletPayload.self)
    }
}
