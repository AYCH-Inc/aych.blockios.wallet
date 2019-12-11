//
//  Pin.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

/// Model for a user's 4-digit pin
public struct Pin {
    static let invalid = Pin(code: 0000)
    
    /// Checks if this pin is a valid
    public var isValid: Bool {
        return self != Pin.invalid
    }

    /// String representation of the underlying pin
    public var toString: String {
        return pinCode.pinToString
    }
    
    private(set) var pinCode: UInt

    // MARK: - Initializers

    public init(code: UInt) {
        self.pinCode = code
    }
    
    public init?(string: String) {
        guard let code = UInt(string) else { return nil }
        self.init(code: code)
    }

    /// Save using injected parameter
    public func save(using settings: AppSettingsAuthenticating) {
        settings.pin = toString
    }
}

// MARK: - Hashable, Equatable

 extension Pin: Hashable {
    public static func == (lhs: Pin, rhs: Pin) -> Bool {
        return lhs.pinCode == rhs.pinCode
    }

    public func isEqual(_ object: Any?) -> Bool {
        return self.pinCode == (object as? Pin)?.pinCode
    }

    public var hashValue: Int {
        return Int(pinCode)
    }
}

extension UInt {
    var pinToString: String {
        return String(format: "%lu", CUnsignedLongLong(self))
    }
}
