//
//  Pin.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for a user's 4-digit pin
struct Pin {
    static let invalid = Pin(code: 0000)
    
    private(set) var pinCode: UInt

    /// Checks if this pin is a valid
    var isValid: Bool {
        return self != Pin.invalid
    }

    /// String representation of the underlying pin
    var toString: String {
        return pinCode.pinToString
    }

    // MARK: - Initializers

    init(code: UInt) {
        self.pinCode = code
    }
    
    init?(string: String) {
        guard let code = UInt(string) else { return nil }
        self.init(code: code)
    }

    /// Save using injected parameter
    func save(using settings: AppSettingsAuthenticating) {
        settings.pin = toString
    }
}

// MARK: - Hashable, Equatable

extension Pin: Hashable {
    static func == (lhs: Pin, rhs: Pin) -> Bool {
        return lhs.pinCode == rhs.pinCode
    }

    func isEqual(_ object: Any?) -> Bool {
        return self.pinCode == (object as? Pin)?.pinCode
    }

    var hashValue: Int {
        return Int(pinCode)
    }
}

extension UInt {
    var pinToString: String {
        return String(format: "%lu", CUnsignedLongLong(self))
    }
}
