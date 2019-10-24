//
//  EthereumAddress.swift
//  EthereumKit
//
//  Created by Jack on 20/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import web3swift

public enum AddressValidationError: Error {
    case unknown
    case containsInvalidCharacters
    case invalidLength
}

typealias EthereumAddressProtocols = Hashable & ExpressibleByStringLiteral & RawRepresentable

public struct EthereumAddress: EthereumAddressProtocols {
    
    public let rawValue: String
    
    public init(stringLiteral value: String) {
        self.rawValue = Address.toChecksumAddress(value)!
    }
    
    public init?(rawValue value: String) {
        guard let eip55Address = Address.toChecksumAddress(value) else {
            return nil
        }
        self.rawValue = eip55Address
    }
    
    public var isValid: Bool {
        return web3swiftAddress.isValid
    }
}

extension EthereumAddress {
    var web3swiftAddress: web3swift.Address {
        return web3swift.Address(rawValue)
    }
}

public struct EthereumAccountAddress: EthereumAddressProtocols {
    
    public var ethereumAddress: EthereumAddress {
        return EthereumAddress(rawValue: rawValue)!
    }
    
    public let rawValue: String
    
    public init(string address: String) throws {
        try Self.validate(address: address)
        
        let web3swiftAddress = web3swift.Address(address, type: .normal)
        guard web3swiftAddress.isValid else {
            throw AddressValidationError.unknown
        }
        guard let eip55Address = Address.toChecksumAddress(address) else {
            throw AddressValidationError.unknown
        }
        self.rawValue = eip55Address
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = Address.toChecksumAddress(value)!
    }
    
    public init?(rawValue value: String) {
        guard let _ = try? Self.validate(address: value) else {
            return nil
        }
        let accountAddress = web3swift.Address(value, type: .normal)
        guard accountAddress.isValid, let eip55Address = Address.toChecksumAddress(value) else {
            return nil
        }
        self.rawValue = eip55Address
    }
    
    static func validate(address: String) throws {
        let trimmed = address.stringByRemoving(prefix: "0x")
        
        // Check that the address only contains alphanumerics
        guard trimmed.isAlphanumeric else {
            throw AddressValidationError.containsInvalidCharacters
        }
        
        // Check that the normalised address is exactly 40 characters long
        guard trimmed.count == 40 else {
            throw AddressValidationError.invalidLength
        }
    }
}

public struct EthereumContractAddress: EthereumAddressProtocols {
    
    public var ethereumAddress: EthereumAddress {
        return EthereumAddress(rawValue: rawValue)!
    }
    
    public let rawValue: String
    
    public init(stringLiteral value: String) {
        self.rawValue = Address.toChecksumAddress(value)!
    }
    
    public init?(rawValue value: String) {
        guard let eip55Address = Address.toChecksumAddress(value) else {
            return nil
        }
        self.rawValue = eip55Address
    }
}
