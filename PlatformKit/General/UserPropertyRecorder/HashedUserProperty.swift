//
//  HashedUserProperty.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit
import CommonCryptoKit

extension HashedUserProperty {
    public init(key: Key, value: String, truncatesValueIfNeeded: Bool = true) {
        self.init(
            key: key,
            valueHash: value.sha256,
            truncatesValueIfNeeded: truncatesValueIfNeeded
        )
    }
}
