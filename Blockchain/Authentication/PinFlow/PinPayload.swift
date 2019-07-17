//
//  PinPayload.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The payload for authenticating into the wallet using a pin code
struct PinPayload {
    
    /// The pin raw string value
    let pinCode: String

    /// The key for this pin
    let pinKey: String

    /// The value of the PinStoreKeyPair
    let pinValue: String?

    /// Boolean indicating whether the pin should be persisted locally upon successfully validating
    let persistsLocally: Bool

    /// Returns the pin
    var pin: Pin? {
        return Pin(string: pinCode)
    }
    
    init(pinCode: String, pinKey: String, persistsLocally: Bool = false, pinValue: String? = nil) {
        self.pinCode = pinCode
        self.pinKey = pinKey
        self.persistsLocally = persistsLocally
        self.pinValue = pinValue
    }

    init(pinCode: String, keyPair: PinStoreKeyPair, persistsLocally: Bool = false) {
        self.init(pinCode: pinCode, pinKey: keyPair.key, persistsLocally: persistsLocally, pinValue: keyPair.value)
    }
}
